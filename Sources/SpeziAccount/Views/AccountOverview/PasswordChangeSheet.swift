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


    @Environment(Account.self)
    private var account
    @Environment(\.dismiss)
    private var dismiss

    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var newPassword: String = ""
    @State private var repeatPassword: String = ""

    private var passwordValidations: [ValidationRule] {
        accountDetails.accountServiceConfiguration.fieldValidationRules(for: AccountKeys.password) ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                passwordFieldsSection
                    .injectEnvironmentObjects(configuration: accountDetails.accountServiceConfiguration, model: model)
                    .focused($isFocused)
                    .environment(\.accountViewType, .overview(mode: .new))
                    .environment(\.defaultErrorDescription, model.defaultErrorDescription)
            }
                .viewStateAlert(state: $viewState)
                .navigationTitle(Text("CHANGE_PASSWORD", bundle: .module))
#if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        AsyncButton(state: $viewState, action: submitPasswordChange) {
                            if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                                Image(systemName: "checkmark")
                                    .accessibilityLabel("Done")
                            } else {
                                Text("Done", bundle: .module)
                            }
                        }
                            .buttonStyleGlassProminent()
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                            Button(role: .cancel) {
                                dismiss()
                            }
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel", bundle: .module)
                            }
                        }
                    }
                }
                .onDisappear {
                    model.resetModelState() // clears modified details
                }
                .anyModifiers(account.securityRelatedModifiers.map { $0.anyViewModifier })
        }
    }

    @ViewBuilder private var passwordFieldsSection: some View {
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
            PasswordValidationRuleFooter(configuration: accountDetails.accountServiceConfiguration)
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

        account.logger.debug("Saving updated password to AccountService!")

        do {
            try await model.updateAccountDetails(details: accountDetails, using: account)
        } catch {
            if error is CancellationError {
                return
            }
            throw error
        }
        
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
    NavigationStack {
        AccountDetailsReader { account, details in
            PasswordChangeSheet(model: AccountOverviewFormViewModel(account: account, details: details), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(genderIdentity: .male))
        }
}
#endif
