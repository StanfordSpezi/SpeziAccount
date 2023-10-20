//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


struct DefaultSignupFormHeader: View {
    var body: some View {
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
            Text("UP_SIGNUP_INSTRUCTIONS", bundle: .module)
                .padding([.leading, .trailing], 25)
        }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .padding(.top, -3)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}


/// A generalized signup form used with arbitrary ``AccountService`` implementations.
///
/// A `Form` that collects all configured account values (a ``AccountValueConfiguration`` supplied to ``AccountConfiguration``)
/// split into `Section`s according the their ``AccountKeyCategory`` (see ``AccountKey/category``).
///
/// - Note: This view is built with the assumption to be placed inside a `NavigationStack` within a Sheet modifier.
public struct SignupForm<Service: AccountService, Header: View>: View {
    private let service: Service
    private let header: Header

    @EnvironmentObject private var account: Account
    @Environment(\.dismiss) private var dismiss

    @StateObject private var signupDetailsBuilder = SignupDetails.Builder()
    @StateObject private var validationEngines = ValidationEngines<String>()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountKey.Type/focusState`

    @State private var presentingCloseConfirmation = false

    private var accountKeyByCategory: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        var result = account.configuration.allCategorized(filteredBy: [.required, .collected])

        // patch the user configured account values with account values additionally required by
        for entry in service.configuration.requiredAccountKeys {
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

    @ViewBuilder var form: some View {
        Form {
            header

            SignupSectionsView(for: SignupDetails.self, service: service, sections: accountKeyByCategory)
                .environment(\.accountServiceConfiguration, service.configuration)
                .environment(\.accountViewType, .signup)
                .environmentObject(signupDetailsBuilder)
                .environmentObject(validationEngines)
                .environmentObject(FocusStateObject(focusedField: $focusedDataEntry))

            AsyncButton(state: $viewState, action: signupButtonAction) {
                Text("UP_SIGNUP", bundle: .module)
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                .disabled(!validationEngines.allInputValid)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }


    init(using service: Service) where Header == DefaultSignupFormHeader {
        self.service = service
        self.header = DefaultSignupFormHeader()
    }

    init(service: Service, @ViewBuilder header: () -> Header) {
        self.service = service
        self.header = header()
    }


    private func signupButtonAction() async throws {
        guard validationEngines.validateSubviews(focusState: $focusedDataEntry) else {
            return
        }

        focusedDataEntry = nil

        let details: SignupDetails = try signupDetailsBuilder.build(checking: account.configuration)

        try await service.signUp(signupDetails: details)

        // go back if the view doesn't update anyway
        dismiss()
    }
}


#if DEBUG
struct DefaultUserIdPasswordSignUpView_Previews: PreviewProvider {
    static let accountService = MockUserIdPasswordAccountService()

    static var previews: some View {
        NavigationStack {
            SignupForm(using: accountService)
        }
            .environmentObject(Account(accountService))
    }
}
#endif
