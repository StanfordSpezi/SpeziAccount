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

    /// The Views Title and subtitle text.
    @ViewBuilder
    var header: some View {
        // TODO provide customizable with AccountViewStyle!
        Text("Welcome back!") // TODO localize
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("Please create an account to do whatever. You may create an account if you don't have one already!") // TODO localize!
            .multilineTextAlignment(.center)
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
                    NameTextFields(name: $name, focusState: _focusedField)
                }
            }

            if !signUpOptions.isDisjoint(with: [.dateOfBirth, .genderIdentity]) {
                Section("Personal Details") {
                    if signUpOptions.contains(.dateOfBirth) {
                        DateOfBirthPicker(date: $dateOfBirth)
                    }

                    if signUpOptions.contains(.genderIdentity) {
                        GenderIdentityPicker(genderIdentity: $genderIdentity)
                    }
                }
            }

            Button(action: signupButtonAction) {
                Text("Signup")
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .replaceWithProcessingIndicator(ifProcessing: state)
            }
                .buttonStyle(.borderedProminent)
                .disabled(state == .processing)
                .padding()
                .padding(-34)
                .listRowBackground(Color.clear)
        }
    }

    init(using service: Service, signUpOptions: SignUpOptions) {
        self.service = service
        self.signUpOptions = signUpOptions
    }

    private func signupButtonAction() {
        guard state != .processing else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            focusedField = .none
            state = .processing
        }

        // TODO save task handle?
        Task {
            do {
                try await service.signUp(signUpValues: SignUpValues(
                    username: userId, // TODO rename signupValues name!
                    password: password,
                    name: name,
                    genderIdentity: genderIdentity,
                    dateOfBirth: dateOfBirth
                ))

                withAnimation(.easeIn(duration: 0.2)) {
                    state = .idle
                }
            } catch {
                state = .error(
                    AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "ERROR" // TODO localization!
                    )
                )
            }
        }
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
