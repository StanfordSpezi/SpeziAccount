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


/// A generalized signup form used with arbitrary ``AccountService`` implementations.
///
/// A `Form` that collects all configured account values (a ``AccountValueConfiguration`` supplied to ``AccountConfiguration``)
/// split into `Section`s according the their ``AccountKeyCategory`` (see ``AccountKey/category``).
public struct SignupForm<Service: AccountService, Header: View>: View {
    private let service: Service
    private let header: Header

    @EnvironmentObject private var account: Account
    @Environment(\.dismiss) private var dismiss

    @StateObject private var signupDetailsBuilder = SignupDetails.Builder()
    @StateObject private var validationEngines = ValidationEngines<String>()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountKey.Type/focusState`


    private var signupValuesBySections: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        account.configuration.reduce(into: [:]) { result, configuration in
            guard configuration.requirement != .supported else {
                // we only show required and collected values in signup
                return
            }

            result[configuration.key.category, default: []] += [configuration.key]
        }
    }


    public var body: some View {
        form
            .navigationTitle(Text("UP_SIGNUP", bundle: .module))
            .disableDismissiveActions(isProcessing: viewState)
            .viewStateAlert(state: $viewState)
    }

    @ViewBuilder var form: some View {
        Form {
            header

            sectionsView
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
                .disabled(!validationEngines.allInputValid)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }

    @ViewBuilder var sectionsView: some View {
        // OrderedDictionary `elements` conforms to RandomAccessCollection so we can directly use it
        ForEach(signupValuesBySections.elements, id: \.key) { category, accountKeys in
            Section {
                // the array doesn't change, so its fine to rely on the indices as identifiers
                ForEach(accountKeys.indices, id: \.self) { index in
                    VStack {
                        accountKeys[index].emptyDataEntryView(for: SignupDetails.self)
                    }
                }
            } header: {
                if let title = category.categoryTitle {
                    Text(title)
                }
            } footer: {
                if category == .credentials && account.configuration[PasswordKey.self] != nil {
                    PasswordValidationRuleFooter(configuration: service.configuration)
                }
            }
        }
    }


    init(using service: Service) where Header == Text {
        self.service = service
        self.header = Text("UP_SIGNUP_INSTRUCTIONS", bundle: .module)
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

        let request: SignupDetails = try signupDetailsBuilder.build(checking: account.configuration)

        try await service.signUp(signupDetails: request)

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
