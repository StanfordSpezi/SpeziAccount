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


public struct DefaultSignupFormHeader: View { // TODO: generalize this view?
    public var body: some View { // TODO: rename or however we want to make it public!
        VStack {
            VStack {
                Image(systemName: "person.fill.badge.plus")
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.multicolor)
                    .font(.custom("XXL", size: 50, relativeTo: .title))
                    .accessibilityHidden(true)
                Text("UP_SIGNUP_HEADER", bundle: .module)
                    .accessibilityAddTraits(.isHeader)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)
            }
                .accessibilityElement(children: .combine)
            Text("UP_SIGNUP_INSTRUCTIONS", bundle: .module)
                .padding([.leading, .trailing], 25)
        }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    public init() {}
}

#if DEBUG
#Preview {
    DefaultSignupFormHeader() // TODO: move into its own file!
}
#endif


/// A generalized signup form used with arbitrary ``AccountService`` implementations.
///
/// A `Form` that collects all configured account values (a ``AccountValueConfiguration`` supplied to ``AccountConfiguration``)
/// split into `Section`s according the their ``AccountKeyCategory`` (see ``AccountKey/category``).
///
/// - Note: This view is built with the assumption to be placed inside a `NavigationStack` within a Sheet modifier.
public struct SignupForm<Header: View>: View {
    private let header: Header
    private let signupClosure: (AccountDetails) async throws -> Void

    @Environment(Account.self) private var account
    @Environment(\.dismiss) private var dismiss

    @State private var signupDetailsBuilder = AccountValuesBuilder()
    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var presentingCloseConfirmation = false

    @MainActor private var accountKeyByCategory: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        var result = account.configuration.allCategorized(filteredBy: [.required, .collected])

        // patch the user configured account values with account values additionally required by
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
                    Button(action: {
                        if signupDetailsBuilder.isEmpty {
                            dismiss()
                        } else {
                            presentingCloseConfirmation = true
                        }
                    }) {
                        Text("CLOSE", bundle: .module)
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
                // TODO: try to replace all account service access just for configuration
                .environment(\.accountServiceConfiguration, account.accountService.configuration)
                .environment(\.accountViewType, .signup)
                .environment(signupDetailsBuilder)

            AsyncButton(state: $viewState, action: signupButtonAction) {
                Text("UP_SIGNUP", bundle: .module)
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                .disabled(!validation.allInputValid)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            .receiveValidation(in: $validation)
    }

    public init(signup: @escaping (AccountDetails) async throws -> Void, @ViewBuilder header: () -> Header = { DefaultSignupFormHeader() }) {
        self.header = header()
        self.signupClosure = signup
    }


    @MainActor
    private func signupButtonAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        // TODO: can we split that into the credentials and user details?
        let details = signupDetailsBuilder.build()
        try details.validateAgainstSignupRequirements(account.configuration)

        try await signupClosure(details)

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
            AccountConfiguration(service: MockAccountService())
        }
}
#endif
