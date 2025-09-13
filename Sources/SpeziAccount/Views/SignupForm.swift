//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziValidation
import SpeziViews
import SwiftUI


/// A generalized signup form used with arbitrary ``AccountService`` implementations.
///
/// A `Form` that collects all configured account values (a ``AccountValueConfiguration`` supplied to ``AccountConfiguration``)
/// split into `Section`s according the their ``AccountKeyCategory`` (see ``AccountKey/category``).
///
/// - Note: This view is built with the assumption to be placed inside a `NavigationStack` within a Sheet modifier.
public struct SignupForm<Header: View>: View {
    private let header: Header
    private let signupClosure: (AccountDetails) async throws -> Void

    @Environment(Account.self)
    private var account
    @Environment(\.dismiss)
    private var dismiss

    @State private var signupDetailsBuilder = AccountDetailsBuilder()
    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var compliance: SignupProviderCompliance?
    @State private var presentingCloseConfirmation = false

    @MainActor private var accountKeyByCategory: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        var result = account.configuration.allCategorized(
            filteredBy: [.required, .collected],
            requiredOptions: [.display, .mutable] // all values provided at signup must be mutable, we already enforce this in `ConfiguredAccountKey`
        )

        // do not show fields that are already present on an anonymous account
        if let details = account.details, details.isAnonymous {
            result = result
                .mapValues { keys in
                    keys.filter { !details.contains($0) }
                }
                .filter { _, keys in
                    !keys.isEmpty
                }
        }

        // patch the user configured account values with account values additionally required by the account service
        for entry in account.accountService.configuration.requiredAccountKeys {
            let key = entry.key
            if !result[key.category, default: []].contains(where: { $0 == key }) {
                result[key.category, default: []].append(key)
            }
        }

        return result
    }


    public var body: some View {
        form
            .disableDismissiveActions(isProcessing: viewState)
            .viewStateAlert(state: $viewState)
            .interactiveDismissDisabled(!signupDetailsBuilder.isEmpty)
            .reportSignupProviderCompliance(compliance)
            .confirmationDialog(
                Text("CONFIRMATION_DISCARD_INPUT_TITLE", bundle: .module),
                isPresented: $presentingCloseConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .destructive, action: {
                    dismiss()
                }) {
                    Text("CONFIRMATION_DISCARD_INPUT", bundle: .module)
                }
                Button(role: .cancel, action: {}) {
                    Text("CONFIRMATION_KEEP_EDITING", bundle: .module)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                        Button(role: .close) {
                            closeButtonAction()
                        }
                    } else {
                        Button(action: {
                            closeButtonAction()
                        }) {
                            Text("Close", bundle: .module)
                        }
                    }
                }
            }
    }

    @MainActor @ViewBuilder var form: some View {
        Form {
            header
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .padding(.top, -3)

            SignupSectionsView(sections: accountKeyByCategory)
                .environment(\.accountServiceConfiguration, account.accountService.configuration)
                .environment(\.accountViewType, .signup)
                .environment(signupDetailsBuilder)

            AsyncButton(state: $viewState, action: signupButtonAction) {
                Text("UP_SIGNUP", bundle: .module)
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyleGlassProminent(backup: .borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                .disabled(!validation.allInputValid)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            .receiveValidation(in: $validation)
    }

    public init(signup: @escaping (AccountDetails) async throws -> Void, @ViewBuilder header: () -> Header = { SignupFormHeader() }) {
        self.header = header()
        self.signupClosure = signup
    }

    
    private func closeButtonAction() {
        if signupDetailsBuilder.isEmpty {
            dismiss()
        } else {
            presentingCloseConfirmation = true
        }
    }

    @MainActor
    private func signupButtonAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        let details = signupDetailsBuilder.build()

        if let anonymousDetails = account.details,
           anonymousDetails.isAnonymous {
            // anonymous accounts will be merged, therefore, details need to be combined fore verifying requirements
            var combined = details
            combined.add(contentsOf: anonymousDetails)
            try combined.validateAgainstSignupRequirements(account.configuration)
        } else {
            try details.validateAgainstSignupRequirements(account.configuration)
        }

        compliance = .compliant
        do {
            try await signupClosure(details)
        } catch {
            compliance = nil
            throw error
        }
        
        dismiss()
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        SignupForm { signupDetails in
            print("Signup Details: \(signupDetails)")
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
