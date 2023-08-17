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

    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    private var passwordValidations: [ValidationRule] {
        accountDetails.accountServiceConfiguration.fieldValidationRules(for: \.password)
    }

    // TODO duplicate! (reconstruct?) just forward?
    private var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: accountDetails.accountServiceConfiguration, focusedField: _focusedDataEntry, viewState: $viewState)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PasswordKey.DataEntry($newPassword)
                        .environment(\.passwordFieldType, .new)
                        .managedValidation(input: newPassword, for: PasswordKey.focusState, rules: passwordValidations)

                    PasswordKey.DataEntry($repeatPassword)
                        .environment(\.passwordFieldType, .repeat)
                        .focused($focusedDataEntry, equals: "$-newPassword")
                        .managedValidation(input: repeatPassword, for: "$-newPassword", rules: passwordEqualityValidation(new: $newPassword))
                } footer: {
                    PasswordValidationRuleFooter(configuration: accountDetails.accountServiceConfiguration)
                }
                    .environmentObject(dataEntryConfiguration)
                    .environmentObject(model.validationClosures)
                    .environmentObject(model.modifiedDetailsBuilder)
            }
                .viewStateAlert(state: $viewState)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription) // TODO more password specific default error?
                .navigationTitle(Text("CHANGE_PASSWORD", bundle: .module))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        AsyncButton(state: $viewState, action: submitPasswordChange) {
                            Text("DONE", bundle: .module)
                        }
                    }
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("CANCEL", bundle: .module)
                        }
                    }
                }
                .onDisappear {
                    model.resetModelState() // clears modified details, and validation closures
                }
        }
    }

    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }

    func submitPasswordChange() async throws {
        guard model.validationClosures.validateSubviews(focusState: $focusedDataEntry) else {
            return // TODO setting the focus thing doesn't work!
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
