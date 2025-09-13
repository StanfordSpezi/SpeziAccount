//
// This source file is part of the Stanford Spezi open-source project
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


/// A default implementation for the embedded view of a ``UserIdPasswordAccountService``.
///
/// Every ``EmbeddableAccountService`` might provide a view that is directly integrated into the ``AccountSetup``
/// view for more easy navigation. This view implements such a view for ``UserIdPasswordAccountService``-based
/// account service implementations.
struct LoginSetupView<PasswordReset: View>: View {
    private let loginClosure: (UserIdPasswordCredential) async throws -> Void
    private let passwordReset: PasswordReset
    private let supportsSignup: Bool

    @Binding private var presentingSignupSheet: Bool

    @Environment(Account.self)
    private var account

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: LoginFocusState?

    // for login we do all checks server-side. Except that we don't pass empty values.
    @ValidationState private var validation
    @State private var presentingPasswordForgetSheet = false

    @MainActor private var userIdConfiguration: UserIdConfiguration {
        account.accountService.configuration.userIdConfiguration
    }

    var body: some View {
        VStack {
            fields
                .padding(.vertical, 0)

            AsyncButton(state: $state, action: loginButtonAction) {
                Text("UP_LOGIN", bundle: .module)
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyleGlassProminent(backup: .borderedProminent)
                .disabled(!validation.allInputValid)
                .environment(\.defaultErrorDescription, .init("UP_LOGIN_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding(.bottom, 12)
                .padding(.top)


            if supportsSignup {
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
        }
            .disableDismissiveActions(isProcessing: state)
            .viewStateAlert(state: $state)
            .receiveValidation(in: $validation)
            .sheet(isPresented: $presentingPasswordForgetSheet) {
                passwordReset
            }
    }


    @ViewBuilder @MainActor private var fields: some View {
        VStack { // swiftlint:disable:this closure_body_length
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
#if os(macOS)
                                .foregroundColor(Color(nsColor: .systemGray))
#else
                                .foregroundColor(Color(uiColor: .systemGray))
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


    init(
        loginClosure: @escaping (UserIdPasswordCredential) async throws -> Void,
        passwordReset: PasswordReset,
        supportsSignup: Bool,
        presentingSignup: Binding<Bool>
    ) {
        self.loginClosure = loginClosure
        self.passwordReset = passwordReset
        self.supportsSignup = supportsSignup
        self._presentingSignupSheet = presentingSignup
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
