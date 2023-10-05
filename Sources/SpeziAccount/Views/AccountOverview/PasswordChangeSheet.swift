//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct PasswordChangeSheet: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }


    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    private var passwordValidations: [ValidationRule] {
        accountDetails.accountServiceConfiguration.fieldValidationRules(for: \.password) ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                passwordFieldsSection
                    .injectEnvironmentObjects(service: service, model: model, focusState: $focusedDataEntry)
                    .environment(\.accountViewType, .overview(mode: .new))
            }
                .viewStateAlert(state: $viewState)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription)
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
                    .focused($focusedDataEntry, equals: PasswordKey.focusState)
                    .managedValidation(input: newPassword, for: PasswordKey.focusState, rules: passwordValidations)
                    .onChange(of: newPassword) { newValue in
                        // A workaround to execute the validation engine of the repeat field if it contains content.
                        // It works, as we only have two validation engines in this view.
                        if !newValue.isEmpty && !repeatPassword.isEmpty {
                            model.validationEngines.validateSubviews() // don't supply focus state. Must not switch focus here!
                        }

                        model.modifiedDetailsBuilder.set(\.password, value: newPassword)
                    }

                Divider()
                    .gridCellUnsizedAxes(.horizontal)

                PasswordKey.DataEntry($repeatPassword)
                    .environment(\.passwordFieldType, .repeat)
                    .focused($focusedDataEntry, equals: "$-newPassword")
                    .managedValidation(input: repeatPassword, for: "$-newPassword", rules: passwordEqualityValidation(new: $newPassword))
                    .environment(\.validationEngineConfiguration, .hideFailedValidationOnEmptySubmit)
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
        guard model.validationEngines.validateSubviews(focusState: $focusedDataEntry) else {
            return
        }

        focusedDataEntry = nil

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

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())

    // be aware, modifications won't be displayed due to declaration in PreviewProvider that do not trigger an UI update
    @StateObject static var model = AccountOverviewFormViewModel(account: account)

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                PasswordChangeSheet(model: model, details: details)
            }
        }
        .environmentObject(account)
    }
}
#endif
