//
// Created by Andreas Bauer on 26.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

struct DefaultUserIdPasswordSignUpView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private let signUpOptions: SignUpOptions

    @State private var userId = ""
    @State private var password = ""
    @State private var name = PersonNameComponents()
    @State private var dateOfBirth = Date()
    @State private var genderIdentity: GenderIdentity = .preferNotToState

    // TODO valid state!

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: AccountInputFields?

    var body: some View {
        form
            .navigationTitle("Sign Up")
            .navigationBarBackButtonHidden(state == .processing)
            .interactiveDismissDisabled(state == .processing)
            .viewStateAlert(state: $state)
    }

    @ViewBuilder
    var form: some View {
        Form {
            Text("Thanks for creating a new account and stuff!") // TODO localize!

            if signUpOptions.contains(.usernameAndPassword) { // TODO isn't that required?
                Section("Credentials") {
                    TextField("E-Mail or Username", text: $userId)
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                }
            }

            if signUpOptions.contains(.name) {
                Section("Name") {
                    // TODO validity?
                    NameTextFields(name: $name, focusState: _focusedField)
                }
            }

            if !signUpOptions.isDisjoint(with: [.dateOfBirth, .genderIdentity]) {
                Section("Personal Details") {
                    if signUpOptions.contains(.dateOfBirth) {
                        // TODO validity?
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

    init(using service: Service, signUpOptions: SignUpOptions) {
        self.service = service
        self.signUpOptions = signUpOptions
    }

    private func signupButtonAction() async throws {
        // TODO verify content!

        try await service.signUp(signUpValues: SignUpValues(
            username: userId, // TODO rename signupValues name!
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
            DefaultUserIdPasswordSignUpView(using: DefaultUsernamePasswordAccountService(), signUpOptions: .default)
        }
    }
}
#endif
