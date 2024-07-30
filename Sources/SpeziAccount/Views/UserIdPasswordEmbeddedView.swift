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


private enum LoginFocusState {
    case userId
    case password
}

public struct UserIdPasswordCredential: Sendable { // TODO: new credentials hierarchy?
    public let userId: String
    public let password: String
}


// TODO: environment variable that controls default layout (also applies to the sign in with apple button?)
public struct SignupSetupView<Signup: View, PasswordReset: View>: View {
    private let loginClosure: (UserIdPasswordCredential) async throws -> Void
    private let signupForm: Signup
    private let passwordReset: PasswordReset

    @State private var presentingSignupSheet = false
    @State private var presentingLoginSheet = false

    public var body: some View {
        VStack {
            AccountServiceButton("Signup") {
                presentingSignupSheet = true
            }
                .padding(.bottom, 12)

            HStack {
                Text("Already got an Account?", bundle: .module)
                Button(action: {
                    presentingLoginSheet = true
                }) {
                    Text("Login", bundle: .module)
                }
            }
                .font(.footnote)
        }
            .sheet(isPresented: $presentingSignupSheet) {
                signupForm
            }
            .sheet(isPresented: $presentingLoginSheet) {
                // TODO: instead of popping sheet, just transform the whole thing into the UserIdPasswordEmbeeddedView?
                NavigationStack {
                    UserIdPasswordEmbeddedView(login: loginClosure, passwordReset: { passwordReset })
                }
                    .presentationDetents([.medium])
            }
    }

    /// Create a new setup view.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account.
    ///   - passwordReset: A closure that is called if the user requests to reset their password.
    public init( // TODO: update docs!
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup,
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.loginClosure = login
        self.signupForm = signupForm()
        self.passwordReset = passwordReset()
    }


    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<DefaultSignupFormHeader>>,
            PasswordReset == NavigationStack<NavigationPath, UserIdPasswordResetView<SuccessfulPasswordResetView>> {
        self.init(login: login) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        } passwordReset: {
            NavigationStack {
                UserIdPasswordResetView(resetPassword: resetPassword)
            }
        }
    }
}


/// A default implementation for the embedded view of a ``UserIdPasswordAccountService``.
///
/// Every ``EmbeddableAccountService`` might provide a view that is directly integrated into the ``AccountSetup``
/// view for more easy navigation. This view implements such a view for ``UserIdPasswordAccountService``-based
/// account service implementations.
public struct UserIdPasswordEmbeddedView<Signup: View, PasswordReset: View>: View {
    private let loginClosure: (UserIdPasswordCredential) async throws -> Void
    private let signupForm: Signup
    private let passwordReset: PasswordReset

    @Environment(Account.self) private var account

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: LoginFocusState?

    // for login we do all checks server-side. Except that we don't pass empty values.
    @ValidationState private var validation

    @State private var presentingSignupSheet = false
    @State private var presentingPasswordForgetSheet = false

    @MainActor private var userIdConfiguration: UserIdConfiguration {
        account.accountService.configuration.userIdConfiguration
    }

    public var body: some View {
        VStack {
            fields
                .padding(.vertical, 0)

            AsyncButton(state: $state, action: loginButtonAction) {
                Text("UP_LOGIN", bundle: .module)
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .disabled(!validation.allInputValid)
                .environment(\.defaultErrorDescription, .init("UP_LOGIN_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding(.bottom, 12)
                .padding(.top)


            if !(signupForm is EmptyView) {
                HStack {
                    Text("UP_NO_ACCOUNT_YET", bundle: .module)
                    Button(action: {
                        presentingSignupSheet = true
                    }) {
                        Text("UP_SIGNUP", bundle: .module)
                    }
                }
                    .font(.footnote)
            }
            // TODO: otherwise add some padding?
        }
            .disableDismissiveActions(isProcessing: state)
            .viewStateAlert(state: $state)
            .receiveValidation(in: $validation)
            .sheet(isPresented: $presentingSignupSheet) {
                signupForm
            }
            .sheet(isPresented: $presentingPasswordForgetSheet) {
                passwordReset
            }
            .onTapGesture {
                focusedField = nil
            }
    }


    @ViewBuilder @MainActor private var fields: some View {
        VStack {
            Group {
                VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                    .validate(input: userId, rules: .nonEmpty)
                    .focused($focusedField, equals: .userId)
                    .textContentType(userIdConfiguration.textContentType)
#if !os(macOS)
                    .keyboardType(userIdConfiguration.keyboardType)
#endif
                    .padding(.bottom, 0.5)

                VerifiableTextField(.init("UP_PASSWORD", bundle: .atURL(from: .module)), text: $password, type: .secure) {
                    if !(passwordReset is EmptyView) {
                        Button(action: {
                            presentingPasswordForgetSheet = true
                        }) {
                            Text("UP_FORGOT_PASSWORD", bundle: .module)
                                .font(.caption)
                                .bold()
#if !os(macOS)
                                .foregroundColor(Color(uiColor: .systemGray)) // TODO: macos
#endif
                        }
                    }
                }
                    .validate(input: password, rules: .nonEmpty)
                    .focused($focusedField, equals: .userId)
                    .textContentType(.password)

                if passwordReset is EmptyView {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: 10)
                }
            }
                .environment(\.validationConfiguration, .hideFailedValidationOnEmptySubmit)
                .disableFieldAssistants()
                .textFieldStyle(.roundedBorder)
                .font(.title3)
        }
    }


    /// Create a new setup view.
    /// - Parameters:
    ///   - login: A closure that is called once a user tries to login with their credentials.
    ///   - signup: A closure that is called if the user tries to signup for an new account.
    ///   - passwordReset: A closure that is called if the user requests to reset their password.
    public init( // TODO: update docs!
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() },
        @ViewBuilder passwordReset: () -> PasswordReset = { EmptyView() }
    ) {
        self.loginClosure = login
        self.signupForm = signupForm()
        self.passwordReset = passwordReset()
    }


    public init( // TODO: update docs
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        @ViewBuilder signup signupForm: () -> Signup = { EmptyView() }
    ) where PasswordReset == EmptyView {
        self.init(login: login, signup: signupForm) {
            EmptyView()
        }
    }


    @MainActor
    public init(
        login: @escaping (UserIdPasswordCredential) async throws -> Void,
        signup: @escaping (AccountDetails) async throws -> Void,
        resetPassword: @escaping (String) async throws -> Void
    ) where Signup == NavigationStack<NavigationPath, SignupForm<DefaultSignupFormHeader>>,
            PasswordReset == NavigationStack<NavigationPath, UserIdPasswordResetView<SuccessfulPasswordResetView>> {
        self.init(login: login) {
            NavigationStack {
                SignupForm(signup: signup)
            }
        } passwordReset: {
            NavigationStack {
                UserIdPasswordResetView(resetPassword: resetPassword)
            }
        }
    }


    @MainActor
    private func loginButtonAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        focusedField = nil

        let credential = UserIdPasswordCredential(userId: userId, password: password)
        try await loginClosure(credential)
    }
}


#if DEBUG
#Preview {
    let service = MockAccountService()
    return SignupSetupView { credential in
        print("Login \(credential)")
    } signup: { details in
        print("Signup \(details)")
    } resetPassword: { userId in
        print("Reset password for \(userId)")
    }
        .previewWith {
            AccountConfiguration(service: service)
        }
}

#Preview {
    let service = MockAccountService()
    return NavigationStack {
        UserIdPasswordEmbeddedView { credential in
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
        UserIdPasswordEmbeddedView { credential in
            print("Login \(credential)")
        }
    }
        .previewWith {
            AccountConfiguration(service: MockAccountService())
        }
}
#endif
