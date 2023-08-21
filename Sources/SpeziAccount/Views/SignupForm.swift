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


public struct SignupForm<Service: AccountService, Header: View>: View {
    private let service: Service
    private let header: Header

    @EnvironmentObject private var account: Account
    @Environment(\.dismiss) private var dismiss
    @Environment(\.logger) private var logger

    @StateObject private var signupDetailsBuilder = SignupDetails.Builder()
    @StateObject private var validationClosures = ValidationClosures<String>()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountValueKey.Type/focusState`


    private var signupValuesBySections: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        account.configuration.reduce(into: [:]) { result, configuration in
            guard configuration.requirement != .supported else {
                // we only show required and collected values in signup
                return
            }

            result[configuration.key.category, default: []] += [configuration.key]
        }
    }

    private var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: service.configuration, focusedField: _focusedDataEntry)
    }


    public var body: some View {
        form
            .navigationTitle(Text("UP_SIGNUP", bundle: .module))
            .disableDismissiveActions(isProcessing: viewState)
            .viewStateAlert(state: $viewState)
            .submitLabel(.done)
    }

    @ViewBuilder var form: some View {
        Form {
            header

            sectionsView
                .environmentObject(validationClosures)
                .environmentObject(dataEntryConfiguration)
                .environmentObject(signupDetailsBuilder)

            AsyncButton(state: $viewState, action: signupButtonAction) {
                Text("UP_SIGNUP".localized(.module))
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
        }
            .environment(\.defaultErrorDescription, .init("UP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }

    @ViewBuilder var sectionsView: some View {
        // OrderedDictionary `elements` conforms to RandomAccessCollection so we can directly use it
        ForEach(signupValuesBySections.elements, id: \.key) { category, accountValues in
            Section {
                // the array doesn't change, so its fine to rely on the indices as identifiers
                ForEach(accountValues.indices, id: \.self) { index in
                    VStack {
                        accountValues[index].emptyDataEntryView(for: SignupDetails.self)
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
        self.header = Text("UP_SIGNUP_INSTRUCTIONS".localized(.module))
    }

    init(service: Service, @ViewBuilder header: () -> Header) {
        self.service = service
        self.header = header()
    }


    private func signupButtonAction() async throws {
        guard validationClosures.validateSubviews(focusState: $focusedDataEntry) else {
            return
        }

        focusedDataEntry = nil

        let request: SignupDetails = try signupDetailsBuilder.build(checking: account.configuration)

        try await service.signUp(signupDetails: request)

        if !account.signedIn {
            logger.error("Didn't find any AccountDetails provided after the signup call to \(Service.self). Please verify your AccountService implementation!")
        }

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
