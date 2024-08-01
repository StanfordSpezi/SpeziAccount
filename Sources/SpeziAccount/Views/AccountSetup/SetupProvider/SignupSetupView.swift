//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import SwiftUI


struct SignupSetupView<Credential: Sendable>: View {
    private let loginClosure: ((Credential) async throws -> Void)?

    @Binding private var setupStyle: PresentedSetupStyle<Credential>
    @Binding private var presentingSignupSheet: Bool

    var body: some View {
        VStack {
            AccountServiceButton("Signup") {
                presentingSignupSheet = true
            }
            .padding(.bottom, 12)
            if let loginClosure {
                HStack {
                    Text("Already got an Account?", bundle: .module)
                    Button {
                        setupStyle = .login(loginClosure)
                    } label: {
                        Text("Login", bundle: .module)
                    }
                }
                .font(.footnote)
            }
        }
    }

    /// Create a new setup view.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account.
    ///   - passwordReset: A closure that is called if the user requests to reset their password.
    init( // TODO: update docs!
        style: Binding<PresentedSetupStyle<Credential>>,
        login loginClosure: ((Credential) async throws -> Void)?,
        presentingSignup: Binding<Bool>
    ) {
        self._setupStyle = style
        self.loginClosure = loginClosure
        self._presentingSignupSheet = presentingSignup
    }
}


#if DEBUG
#Preview {
    @State var style: PresentedSetupStyle<UserIdPasswordCredential> = .signup
    @State var presentingSignup = false

    SignupSetupView(style: $style, login: { _ in }, presentingSignup: $presentingSignup)
        .previewWith {
            AccountConfiguration(service: MockAccountService())
        }
}

#Preview {
    @State var style: PresentedSetupStyle<UserIdPasswordCredential> = .signup
    @State var presentingSignup = false

    SignupSetupView(style: $style, login: nil, presentingSignup: $presentingSignup)
        .previewWith {
            AccountConfiguration(service: MockAccountService())
        }
}
#endif
