//
// Created by Andreas Bauer on 26.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

struct DefaultUserIdPasswordSignUpView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private var signUpOptions: SignUpOptions {
        service.configuration.signUpOptions
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

    @ViewBuilder
    var form: some View {
        Form {
            Text("Thanks for creating a new account and stuff!") // TODO localize!

            if signUpOptions.contains(.usernameAndPassword) { // TODO isn't that required?
                Section("Credentials") {
                    VerifiableTextField("E-Mail or Username", text: $userId)
                        .environmentObject(userIdValidation)
                        .fieldConfiguration(service.configuration.userIdField)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .username)

                    // TODO single password, but with visibility toggle: https://stackoverflow.com/questions/63095851/show-hide-password-how-can-i-add-this-feature
                    VerifiableTextField("Password", text: $password, type: .secure)
                        .environmentObject(passwordValidation)
                        .fieldConfiguration(.newPassword)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .password)
                }
                    .disableFieldAssistants()
            }

            if signUpOptions.contains(.name) {
                Section("Name") {
                    // TODO Name Text Fields with empty validation!
                    NameTextFields(name: $name, focusState: _focusedField)
                }
            }

            if !signUpOptions.isDisjoint(with: [.dateOfBirth, .genderIdentity]) {
                Section("Personal Details") {
                    if signUpOptions.contains(.dateOfBirth) {
                        // TODO validate that user inputted data
                        DateOfBirthPicker(date: $dateOfBirth)
                    }

                    if signUpOptions.contains(.genderIdentity) {
                        GenderIdentityPicker(genderIdentity: $genderIdentity)
                    }
                }
            }

            AsyncDataEntrySubmitButton(state: $state, action: signupButtonAction) {
                Text("Signup")
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                // TODO default error localization!
        }
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
            focusedField = .username
            return
        }

        guard passwordValidation.inputValid else {
            focusedField = .password // TODO does this erase the password?
            return
        }

        try await service.signUp(signUpValues: SignUpValues(
            userId: userId,
            password: password,
            name: name,
            genderIdentity: genderIdentity,
            dateOfBirth: dateOfBirth
        ))
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
