//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
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
public struct UserIdPasswordEmbeddedView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @EnvironmentObject private var account: Account

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: LoginFocusState?

    // for login we do all checks server-side. Except that we don't pass empty values.
    @StateObject private var userIdValidation = ValidationEngine(rules: [.nonEmpty], configuration: .hideFailedValidationOnEmptySubmit)
    @StateObject private var passwordValidation = ValidationEngine(rules: [.nonEmpty], configuration: .hideFailedValidationOnEmptySubmit)

    @State private var presentingSignupSheet = false
    @State private var presentingPasswordForgetSheet = false

    @State private var loginTask: Task<Void, Error>? {
        willSet {
            loginTask?.cancel()
        }
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
                .disabled(!userIdValidation.inputValid || !passwordValidation.inputValid)
                .environment(\.defaultErrorDescription, .init("UP_LOGIN_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding(.bottom, 12)
                .padding(.top)


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
            .disableDismissiveActions(isProcessing: state)
            .viewStateAlert(state: $state)
            .sheet(isPresented: $presentingSignupSheet) {
                NavigationStack {
                    service.viewStyle.makeSignupView()
                }
            }
            .sheet(isPresented: $presentingPasswordForgetSheet) {
                NavigationStack {
                    service.viewStyle.makePasswordResetView()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .onTapGesture {
                focusedField = nil
            }
    }


    @ViewBuilder private var fields: some View {
        VStack {
            Group {
                VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                    .environmentObject(userIdValidation)
                    .textContentType(userIdConfiguration.textContentType)
                    .keyboardType(userIdConfiguration.keyboardType)
                    .onTapFocus(focusedField: $focusedField, fieldIdentifier: .userId)
                    .padding(.bottom, 0.5)

                VerifiableTextField(.init("UP_PASSWORD", bundle: .atURL(from: .module)), text: $password, type: .secure) {
                    Button(action: {
                        presentingPasswordForgetSheet = true
                    }) {
                        Text("UP_FORGOT_PASSWORD", bundle: .module)
                            .font(.caption)
                            .bold()
                            .foregroundColor(Color(uiColor: .systemGray))
                    }
                }
                    .environmentObject(passwordValidation)
                    .textContentType(.password)
                    .onTapFocus(focusedField: $focusedField, fieldIdentifier: .password)
            }
                .disableFieldAssistants()
                .textFieldStyle(.roundedBorder)
                .font(.title3)
        }
    }


    /// Create a new embedded view.
    /// - Parameter service: The ``UserIdPasswordAccountService`` instance.
    public init(using service: Service) {
        self.service = service
    }


    private func loginButtonAction() async throws {
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

        focusedField = nil

        try await service.login(userId: userId, password: password)
    }
}


#if DEBUG
struct DefaultUserIdPasswordBasedEmbeddedView_Previews: PreviewProvider {
    static let accountService = MockUserIdPasswordAccountService()

    static var previews: some View {
        NavigationStack {
            UserIdPasswordEmbeddedView(using: accountService)
        }
            .environmentObject(Account(accountService))
    }
}
#endif
