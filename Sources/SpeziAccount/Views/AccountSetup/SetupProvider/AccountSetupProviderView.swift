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


enum PresentedSetupStyle<Credentials: Sendable> {
    case signup
    case login((Credentials) async throws -> Void)
}


/// A view that provides setup with an identity provider.
///
/// This view guides setup through an identity provider. You might use it as a view supplied to the accounts system using ``IdentityProvider``.
/// It either renders as login with (using userId and password), with optional functionality like password reset and signup, or renders as a signup button.
/// How the view is presented depends on the functionality supported (based on the initializer arguments) and the ``PreferredSetupStyle`` from the environment.
///
/// Password reset functionality is optional. Equally, login and signup are optional, however at least one of both must be supported.
///
/// Below is a short code example, how to provide a userId and password login view with signup and password reset functionality.
/// ```swift
/// AccountSetupProviderView { credential in
///     // handle login credentials
/// } signup: { signupDetails in
///     // handle signup with the provided details
/// } resetPassword: { userId in
///     // handle password reset for the given user id
/// }
/// ```
///
/// - Note: The above code example uses default components like ``SignupForm`` and the ``PasswordResetView``. You can provide your
///     own views using ``init(signup:passwordReset:)``.
public struct AccountSetupProviderView<Signup: View, PasswordReset: View>: View {
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

    private init(
        loginClosure: ((UserIdPasswordCredential) async throws -> Void)? = nil,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() },
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.loginClosure = loginClosure
        self.signupForm = signupForm()
        self.passwordReset = passwordReset()
    }

    /// A setup view that supports login, signup and password reset.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signupForm: The view that is shown as a sheet, if the user presses the signup button. Pass an `EmptyView` if signup isn't supported.
    ///   - passwordReset: The view that is shown as a sheet, if the user presses the "Forgot Password" button. Pass an `EmptyView` if password reset isn't supported.
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() },
        @ViewBuilder passwordReset: () -> PasswordReset
    ) {
        self.init(loginClosure: login, signup: signupForm, passwordReset: passwordReset)
    }


    /// A setup view that supports signup and password reset.
    /// - Parameters:
    ///   - signupForm: The view that is shown as a sheet, if the user presses the signup button.
    ///   - passwordReset: The view that is shown as a sheet, if the user presses the "Forgot Password" button. Pass an `EmptyView` if password reset isn't supported.
    public init(
        @ViewBuilder signup signupForm: () -> Signup,
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.init(loginClosure: nil, signup: signupForm, passwordReset: passwordReset)
    }


    /// A setup view that supports login and signup.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signupForm: The view that is shown as a sheet, if the user presses the signup button. Pass an `EmptyView` if signup isn't supported.
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() }
    ) where PasswordReset == EmptyView {
        self.init(loginClosure: login, signup: signupForm) {
            EmptyView()
        }
    }


    /// A setup view that supports signup.
    /// - Parameters:
    ///   - signupForm: The view that is shown as a sheet, if the user presses the signup button. Pass an `EmptyView` if signup isn't supported.
    public init(
        @ViewBuilder signup signupForm: () -> Signup
    ) where PasswordReset == EmptyView {
        self.init(loginClosure: nil, signup: signupForm) {
            EmptyView()
        }
    }


    /// A setup view that supports login, signup and password reset.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account. The default ``SignupForm`` is used.
    ///   - resetPassword: A closure that is called if the user requests to reset their password. The default ``PasswordResetView`` is used.
    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<SignupFormHeader>>,
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

    /// A setup view that supports login, signup and password reset.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account. The default ``SignupForm`` is used.
    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        signup: @escaping (AccountDetails) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<SignupFormHeader>>, PasswordReset == EmptyView {
        self.init(loginClosure: login) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        }
    }

    /// A setup view that supports signup and password reset.
    /// - Parameters:
    ///   - signup: A closure that is called if the user tries to signup for an new account. The default ``SignupForm`` is used.
    ///   - resetPassword: A closure that is called if the user requests to reset their password. The default ``PasswordResetView`` is used.
    @MainActor
    public init(
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<SignupFormHeader>>,
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

    /// A setup view that supports login and password reset.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - resetPassword: A closure that is called if the user requests to reset their password. The default ``PasswordResetView`` is used.
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

    /// A setup view that supports signup.
    /// - Parameters:
    ///   - signup: A closure that is called if the user tries to signup for an new account. The default ``SignupForm`` is used.
    @MainActor
    public init(
        signup: @escaping (AccountDetails) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<SignupFormHeader>>, PasswordReset == EmptyView {
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
    NavigationStack {
        AccountSetupProviderView { credential in
            print("Login \(credential)")
        } signup: { details in
            print("Signup \(details)")
        } resetPassword: { userId in
            print("Reset password for \(userId)")
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    NavigationStack {
        AccountSetupProviderView { credential in
            print("Login \(credential)")
        } signup: { details in
            print("Signup \(details)")
        } resetPassword: { userId in
            print("Reset password for \(userId)")
        }
    }
        .environment(\.preferredSetupStyle, .signup)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    NavigationStack {
        AccountSetupProviderView { (credential: UserIdPasswordCredential) in
            print("Login \(credential)")
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    NavigationStack {
        AccountSetupProviderView { (details: AccountDetails) in
            print("Signup \(details)")
        } resetPassword: { userId in
            print("Reset password for \(userId)")
        }
    }
    .environment(\.preferredSetupStyle, .signup)
    .previewWith {
        AccountConfiguration(service: InMemoryAccountService())
    }
}
#endif
