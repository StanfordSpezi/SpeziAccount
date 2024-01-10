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
    private let accountDetails: AccountDetails
    private let model: AccountOverviewFormViewModel

    private var service: any AccountService {
        accountDetails.accountService
    }


    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    private var passwordValidations: [ValidationRule] {
        accountDetails.accountServiceConfiguration.fieldValidationRules(for: \.password) ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                passwordFieldsSection
                    .injectEnvironmentObjects(service: service, model: model)
                    .focused($isFocused)
                    .environment(\.accountViewType, .overview(mode: .new))
                    .environment(\.defaultErrorDescription, model.defaultErrorDescription)
            }
                .viewStateAlert(state: $viewState)
                .anyViewModifier(service.viewStyle.securityRelatedViewModifier)
                .navigationTitle(Text("CHANGE_PASSWORD", bundle: .module))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
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
                .onDisappear {
                    model.resetModelState() // clears modified details
                }
        }
    }

    @ViewBuilder private var passwordFieldsSection: some View {
        Section {
            Grid {
                PasswordKey.DataEntry($newPassword)
                    .environment(\.passwordFieldType, .new)
                    .validate(input: newPassword, rules: passwordValidations)
                    .onChange(of: newPassword) {
                        // A workaround to execute the validation engine of the repeat field if it contains content.
                        // It works, as we only have two validation engines in this view.
                        if !newPassword.isEmpty && !repeatPassword.isEmpty {
                            validation.validateSubviews(switchFocus: false) // Must not switch focus here!
                        }

                        model.modifiedDetailsBuilder.set(\.password, value: newPassword)
                    }

                Divider()
                    .gridCellUnsizedAxes(.horizontal)

                PasswordKey.DataEntry($repeatPassword)
                    .environment(\.passwordFieldType, .repeat)
                    .validate(input: repeatPassword, rules: passwordEqualityValidation(new: $newPassword))
                    .environment(\.validationConfiguration, .hideFailedValidationOnEmptySubmit)
            }
        } footer: {
            PasswordValidationRuleFooter(configuration: service.configuration)
        }
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }

    func submitPasswordChange() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        logger.debug("Saving updated password to AccountService!")

        try await model.updateAccountDetails(details: accountDetails)
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
struct PasswordChangeSheet_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static var previews: some View {
        NavigationStack {
            AccountDetailsReader { account, details in
                PasswordChangeSheet(model: AccountOverviewFormViewModel(account: account), details: details)
            }
        }
            .previewWith {
                AccountConfiguration(building: details, active: MockUserIdPasswordAccountService())
            }
    }
}
#endif
