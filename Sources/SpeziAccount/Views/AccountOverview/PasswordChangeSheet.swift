//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziValidation
import SpeziViews
import SwiftUI


@MainActor
struct PasswordChangeSheet: View {
    @Environment(Account.self)
    private var account
    @Environment(AccountOverviewFormViewModel.self)
    private var model
    @Environment(\.dismiss)
    private var dismiss

    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    private var passwordValidations: [ValidationRule] {
        // TODO: Details optional access?
        account.details?.accountServiceConfiguration.fieldValidationRules(for: AccountKeys.password) ?? []
    }

    var body: some View {
        NavigationStack {
            Group {
                if let details = account.details {
                    Form {
                        passwordFieldsSection(for: details)
                            .injectEnvironmentObjects(configuration: details.accountServiceConfiguration, model: model)
                            .focused($isFocused)
                            .environment(\.accountViewType, .overview(mode: .new))
                            .environment(\.defaultErrorDescription, model.defaultErrorDescription)
                    }
                    .viewStateAlert(state: $viewState)
                    .onDisappear {
                        model.resetModelState() // clears modified details
                    }
                    .anyModifiers(account.securityRelatedModifiers.map { $0.anyViewModifier })
                } else {
                    ContentUnavailableView(
                        "No Account",
                        systemImage: "person.crop.square.fill",
                        description: Text("Changing the password requires a signed in user account.")
                    )
                }
            }
                .navigationTitle(Text("CHANGE_PASSWORD", bundle: .module))
    #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
    #endif
                .toolbar {
                    toolbarContent
                }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            AsyncButton(state: $viewState, action: submitPasswordChange) {
                Text("DONE", bundle: .module)
            }
        }
        ToolbarItem(placement: .cancellationAction) {
            Button(action: {
                dismiss()
            }) {
                Text("CANCEL", bundle: .module)
            }
        }
    }

    init() {} // TODO: make public?

    @ViewBuilder
    private func passwordFieldsSection(for details: AccountDetails) -> some View {
        Section {
            Grid {
                AccountKeys.password.DataEntry($newPassword)
                    .environment(\.passwordFieldType, .new)
                    .validate(input: newPassword, rules: passwordValidations)
                    .onChange(of: newPassword) {
                        // A workaround to execute the validation engine of the repeat field if it contains content.
                        // It works, as we only have two validation engines in this view.
                        if !newPassword.isEmpty && !repeatPassword.isEmpty {
                            validation.validateSubviews(switchFocus: false) // Must not switch focus here!
                        }

                        model.modifiedDetailsBuilder.set(AccountKeys.password, value: newPassword)
                    }

                Divider()
                    .gridCellUnsizedAxes(.horizontal)

                AccountKeys.password.DataEntry($repeatPassword)
                    .environment(\.passwordFieldType, .repeat)
                    .validate(input: repeatPassword, rules: passwordEqualityValidation(new: $newPassword))
                    .environment(\.validationConfiguration, .hideFailedValidationOnEmptySubmit)
            }
        } footer: {
            PasswordValidationRuleFooter(configuration: details.accountServiceConfiguration)
        }
    }

    func submitPasswordChange() async throws {
        guard validation.validateSubviews() else {
            return
        }

        guard let details = account.details else {
            return
        }

        isFocused = false

        account.logger.debug("Saving updated password to AccountService!")

        try await model.updateAccountDetails(details: details, using: account)
        dismiss()
    }

    func passwordEqualityValidation(new newPassword: Binding<String>) -> ValidationRule {
        ValidationRule(
            rule: { repeatPassword in
                repeatPassword == newPassword.wrappedValue
            },
            message: "VALIDATION_RULE_PASSWORDS_NOT_MATCHED",
            bundle: .module
        )
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return NavigationStack {
        AccountDetailsReader { account, details in
            PasswordChangeSheet()
                .environment(AccountOverviewFormViewModel(account: account, details: details))
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
