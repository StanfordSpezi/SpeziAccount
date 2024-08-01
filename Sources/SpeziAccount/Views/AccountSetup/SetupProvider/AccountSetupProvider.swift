//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI


public enum PreferredSetupStyle { // TODO: "SetupViewLayout"
    case automatic // TODO: e.g. choose signup if no login closure was specified?
    case login
    case signup
}

enum PresentedSetupStyle<Credentials: Sendable> {
    case signup
    case login((Credentials) async throws -> Void)
}

public struct UserIdPasswordCredential: Sendable { // TODO: new credentials hierarchy?
    public let userId: String
    public let password: String
}


extension EnvironmentValues {
    // TODO: swift 5.10 support
    @Entry var preferredSetupStyle: PreferredSetupStyle = .automatic
}


public struct AccountSetupProvider<Signup: View, PasswordReset: View>: View {
    /// Optional login closure for providers that support userId-password-based credentials.
    private let loginClosure: ((UserIdPasswordCredential) async throws -> Void)?
    /// The view that handles signup.
    private let signupForm: Signup
    /// An optional password reset view. Might be of type `EmptyView`.
    private let passwordReset: PasswordReset

    @Environment(\.preferredSetupStyle)
    private var preferredSetupStyle

    @State private var presentedStyle: PresentedSetupStyle<UserIdPasswordCredential> = .signup
    @State private var presentingSignup = false

    public var body: some View {
        ZStack {
            switch presentedStyle {
            case .signup:
                SignupSetupView(style: $presentedStyle, login: loginClosure, presentingSignup: $presentingSignup)
            case let .login(closure):
                LoginSetupView(
                    loginClosure: closure,
                    passwordReset: passwordReset,
                    supportsSignup: !(signupForm is EmptyView),
                    presentingSignup: $presentingSignup
                )
            }
        }
            .onChange(of: preferredSetupStyle, initial: true) {
                switch preferredSetupStyle {
                case .automatic, .login:
                    if let loginClosure {
                        presentedStyle = .login(loginClosure)
                    } else {
                        assert(!(signupForm is EmptyView), "\(Self.self) must either support login or signup or both.")
                        presentedStyle = .signup
                    }
                case .signup:
                    if signupForm is EmptyView {
                        guard let loginClosure else {
                            preconditionFailure("\(Self.self) must either support login or signup or both.")
                        }
                        presentedStyle = .login(loginClosure)
                    } else {
                        presentedStyle = .signup
                    }
                }
            }
            .sheet(isPresented: $presentingSignup) {
                signupForm
            }
    }

    private init( // TODO: update docs!
        loginClosure: ((UserIdPasswordCredential) async throws -> Void)? = nil,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() },
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.loginClosure = loginClosure
        self.signupForm = signupForm()
        self.passwordReset = passwordReset()
    }

    /// Create a new setup view.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account.
    ///   - passwordReset: A closure that is called if the user requests to reset their password.
    public init( // TODO: update docs!
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() },
        @ViewBuilder passwordReset: () -> PasswordReset
    ) {
        self.init(loginClosure: login, signup: signupForm, passwordReset: passwordReset)
    }


    public init( // TODO: update docs!
        @ViewBuilder signup signupForm: () -> Signup,
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.init(loginClosure: nil, signup: signupForm, passwordReset: passwordReset)
    }


    public init( // TODO: update docs!
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() }
    ) where PasswordReset == EmptyView {
        self.init(loginClosure: login, signup: signupForm) {
            EmptyView()
        }
    }


    public init( // TODO: update docs!
        @ViewBuilder signup signupForm: () -> Signup
    ) where PasswordReset == EmptyView {
        self.init(loginClosure: nil, signup: signupForm) {
            EmptyView()
        }
    }


    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<DefaultSignupFormHeader>>,
            PasswordReset == NavigationStack<NavigationPath, PasswordResetView<SuccessfulPasswordResetView>> {
        self.init(loginClosure: login) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        } passwordReset: {
            NavigationStack {
                PasswordResetView(resetPassword: resetPassword)
            }
        }
    }

    @MainActor
    public init(
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<DefaultSignupFormHeader>>,
    PasswordReset == NavigationStack<NavigationPath, PasswordResetView<SuccessfulPasswordResetView>> {
        self.init(loginClosure: nil) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        } passwordReset: {
            NavigationStack {
                PasswordResetView(resetPassword: resetPassword)
            }
        }
    }

    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == EmptyView,
    PasswordReset == NavigationStack<NavigationPath, PasswordResetView<SuccessfulPasswordResetView>> {
        self.init(loginClosure: login) {
            EmptyView()
        } passwordReset: {
            NavigationStack {
                PasswordResetView(resetPassword: resetPassword)
            }
        }
    }

    @MainActor
    public init(
        signup: @escaping (AccountDetails) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<DefaultSignupFormHeader>>, PasswordReset == EmptyView {
        self.init(loginClosure: nil) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        } passwordReset: {
            EmptyView()
        }
    }
}


#if DEBUG
#Preview {
    let service = MockAccountService()
    return NavigationStack {
        AccountSetupProvider { credential in
            print("Login \(credential)")
        } signup: { details in
            print("Signup \(details)")
        } resetPassword: { userId in
            print("Reset password for \(userId)")
        }
    }
        .previewWith {
            AccountConfiguration(service: service)
        }
}

#Preview {
    NavigationStack {
        AccountSetupProvider { (credential: UserIdPasswordCredential) in
            print("Login \(credential)")
        }
    }
        .previewWith {
            AccountConfiguration(service: MockAccountService())
        }
}
#endif
