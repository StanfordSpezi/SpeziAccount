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
            AccountServiceButton("UP_SIGNUP") {
                presentingSignupSheet = true
            }
            .padding(.bottom, 12)
            if let loginClosure {
                HStack {
                    Text("Already got an Account?", bundle: .module)
                    Button {
                        setupStyle = .login(loginClosure)
                    } label: {
                        Text("UP_LOGIN", bundle: .module)
                    }
                }
                .font(.footnote)
            }
        }
    }

    /// Create a new signup setup view.
    /// - Parameters:
    ///   - stale: The binding to the presented setup style.
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - presentingSignup: Binding if the signup sheet should be presented.
    init(
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

    return SignupSetupView(style: $style, login: { _ in }, presentingSignup: $presentingSignup)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    @State var style: PresentedSetupStyle<UserIdPasswordCredential> = .signup
    @State var presentingSignup = false

    return SignupSetupView(style: $style, login: nil, presentingSignup: $presentingSignup)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
