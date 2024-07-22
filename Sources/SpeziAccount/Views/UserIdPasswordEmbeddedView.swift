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


/// A default implementation for the embedded view of a ``UserIdPasswordAccountService``.
///
/// Every ``EmbeddableAccountService`` might provide a view that is directly integrated into the ``AccountSetup``
/// view for more easy navigation. This view implements such a view for ``UserIdPasswordAccountService``-based
/// account service implementations.
public struct UserIdPasswordEmbeddedView: View {
    private let service: any UserIdPasswordAccountService
    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @Environment(Account.self) private var account

    // for login we do all checks server-side. Except that we don't pass empty values.
    @ValidationState private var validation

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: LoginFocusState?

    @State private var presentingSignupSheet = false
    @State private var presentingPasswordForgetSheet = false

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
            .receiveValidation(in: $validation)
            .sheet(isPresented: $presentingSignupSheet) {
                NavigationStack {
                    service.viewStyle.makeAnySignupForm(service)
                }
            }
            .sheet(isPresented: $presentingPasswordForgetSheet) {
                NavigationStack {
                    service.viewStyle.makeAnyPasswordResetView(service)
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
                    .validate(input: userId, rules: .nonEmpty)
                    .focused($focusedField, equals: .userId)
                    .textContentType(userIdConfiguration.textContentType)
                    .keyboardType(userIdConfiguration.keyboardType)
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
                    .validate(input: password, rules: .nonEmpty)
                    .focused($focusedField, equals: .userId)
                    .textContentType(.password)
            }
                .environment(\.validationConfiguration, .hideFailedValidationOnEmptySubmit)
                .disableFieldAssistants()
                .textFieldStyle(.roundedBorder)
                .font(.title3)
        }
    }


    /// Create a new embedded view.
    /// - Parameter service: The ``UserIdPasswordAccountService`` instance.
    public init(using service: any UserIdPasswordAccountService) {
        self.service = service
    }


    @MainActor
    private func loginButtonAction() async throws {
        guard validation.validateSubviews() else {
            return
        }

        focusedField = nil

        let userId = userId
        let password = password
        try await service.login(userId: userId, password: password)
    }
}


extension UserIdPasswordAccountSetupViewStyle {
    @MainActor
    fileprivate func makeAnySignupForm(_ service: any UserIdPasswordAccountService) -> AnyView {
        AnyView(makeSignupView(service))
    }

    @MainActor
    fileprivate func makeAnyPasswordResetView(_ service: any UserIdPasswordAccountService) -> AnyView {
        AnyView(makePasswordResetView(service))
    }
}


#if DEBUG
#Preview {
    let accountService = MockUserIdPasswordAccountService()
    return NavigationStack {
        UserIdPasswordEmbeddedView(using: accountService)
    }
        .previewWith {
            AccountConfiguration {
                accountService
            }
        }
}
#endif
