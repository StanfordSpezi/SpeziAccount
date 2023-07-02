//
// Created by Andreas Bauer on 26.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

struct DefaultUserIdPasswordSignUpView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private var signupRequirements: AccountValueRequirements {
        service.configuration.signUpRequirements
    }

    @State private var userId = ""
    @State private var password = ""
    @State private var name = PersonNameComponents()
    @State private var dateOfBirth = Date()
    @State private var genderIdentity: GenderIdentity = .preferNotToState

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: AccountInputFields?

    @StateObject var userIdValidation: ValidationEngine
    @StateObject var passwordValidation: ValidationEngine

    var body: some View {
        form
            .navigationTitle("Sign Up")
            .disableAnyDismissiveActions(ifProcessing: state)
            .viewStateAlert(state: $state)
    }

    @ViewBuilder var form: some View {
        Form {
            // TODO form instructions should be customizable!
            Text("UP_SIGNUP_INSTRUCTIONS".localized(.module))

            // TODO both are required?
            if signupRequirements.configured(UserIdAccountValueKey.self) && signupRequirements.configured(PasswordAccountValueKey.self) {
                Section("UP_CREDENTIALS".localized(.module).localizedString()) {
                    VerifiableTextField(service.configuration.userIdType.localizedStringResource, text: $userId)
                        .environmentObject(userIdValidation)
                        .fieldConfiguration(service.configuration.userIdField)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)

                    // TODO single password, but with visibility toggle: https://stackoverflow.com/questions/63095851/show-hide-password-how-can-i-add-this-feature
                    VerifiableTextField("UP_PASSWORD".localized(.module), text: $password, type: .secure)
                        .environmentObject(passwordValidation)
                        .fieldConfiguration(.newPassword)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .password)
                }
                    .disableFieldAssistants()
            }

            // TODO we could also think about a solution where the SignupValue places the
            //  UI element => makes the whole thing more reuseable!
            if signupRequirements.configured(NameAccountValueKey.self) {
                Section("UP_NAME".localized(.module).localizedString()) {
                    // TODO Name Text Fields with empty validation!
                    NameTextFields(name: $name, focusState: _focusedField)
                }
            }

            // TODO this not nice?
            if signupRequirements.configured(DateOfBirthAccountValueKey.self)
                || signupRequirements.configured(GenderIdentityAccountValueKey.self) {
                Section("UP_PERSONAL_DETAILS".localized(.module).localizedString()) {
                    if signupRequirements.configured(DateOfBirthAccountValueKey.self) {
                        // TODO validate that user inputted data
                        DateOfBirthPicker(date: $dateOfBirth)
                    }

                    if signupRequirements.configured(GenderIdentityAccountValueKey.self) {
                        GenderIdentityPicker(genderIdentity: $genderIdentity)
                    }
                }
            }

            AsyncDataEntrySubmitButton(state: $state, action: signupButtonAction) {
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

    init(using service: Service) {
        self.service = service
        self._userIdValidation = StateObject(wrappedValue: ValidationEngine(rules: service.configuration.userIdSignupValidations))
        self._passwordValidation = StateObject(wrappedValue: ValidationEngine(rules: service.configuration.passwordSignupValidations))
    }

    private func signupButtonAction() async throws {
        userIdValidation.runValidation(input: userId)
        passwordValidation.runValidation(input: password)

        guard userIdValidation.inputValid else {
            focusedField = .userId
            return
        }

        guard passwordValidation.inputValid else {
            focusedField = .password
            return
        }

        let requestBuilder = AccountValueStorageBuilder()
            .add(UserIdAccountValueKey.self, value: userId)
            .add(PasswordAccountValueKey.self, value: password)
            .add(NameAccountValueKey.self, value: name)
            .add(GenderIdentityAccountValueKey.self, value: genderIdentity, ifConfigured: signupRequirements)
            .add(DateOfBirthAccountValueKey.self, value: dateOfBirth, ifConfigured: signupRequirements)

        let request: SignupRequest = requestBuilder.build(checking: signupRequirements)

        // TODO we might want to have keys that have optional value but are still displayed!
        try await service.signUp(signupRequest: request)
        // TODO do we impose any requirements, that there should a logged in used after this?
    }
}

#if DEBUG
struct DefaultUserIdPasswordSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordSignUpView(using: DefaultUsernamePasswordAccountService())
        }
    }
}
#endif
