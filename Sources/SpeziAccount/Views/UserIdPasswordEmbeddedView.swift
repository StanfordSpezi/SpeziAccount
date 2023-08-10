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


public struct UserIdPasswordEmbeddedView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private var userIdConfiguration: UserIdConfiguration {
        service.configuration.userIdConfiguration
    }

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var state: ViewState = .idle
    @FocusState private var focusedField: LoginFocusState?

    // for login we do all checks server-side. Except that we don't pass empty values.
    @StateObject private var userIdValidation = ValidationEngine(rules: [.nonEmpty])
    @StateObject private var passwordValidation = ValidationEngine(rules: [.nonEmpty])

    @State private var loginTask: Task<Void, Error>? {
        willSet {
            loginTask?.cancel()
        }
    }

    @MainActor public var body: some View {
        VStack {
            VStack {
                Group {
                    VerifiableTextField(userIdConfiguration.idType.localizedStringResource, text: $userId)
                        .environmentObject(userIdValidation)
                        .textContentType(userIdConfiguration.textContentType)
                        .keyboardType(userIdConfiguration.keyboardType)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .userId)
                        .padding(.bottom, 0.5)

                    // TODO .padding([.leading, .bottom], 8) for the red texts?

                    VerifiableTextField("UP_PASSWORD".localized(.module), text: $password, type: .secure) {
                        NavigationLink(value: "as") {
                            EmptyView()
                        }
                        NavigationLink {
                            service.viewStyle.makePasswordResetView()
                        } label: {
                            Text("UP_FORGOT_PASSWORD".localized(.module))
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                        .environmentObject(passwordValidation)
                        .textContentType(.password)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .password)
                }
                    .disableFieldAssistants()
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
            }
                .padding(.vertical, 0)

            AsyncButton(state: $state, action: loginButtonAction) {
                Text("UP_LOGIN".localized(.module))
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 12)
                .padding(.top)


            HStack {
                Text("UP_NO_ACCOUNT_YET".localized(.module))
                NavigationLink {
                    service.viewStyle.makeSignupView()
                } label: {
                    Text("UP_SIGNUP".localized(.module))
                }
                // TODO .padding(.horizontal, 0)
            }
                .font(.footnote)
        }
            .disableDismissiveActions(isProcessing: state)
            .viewStateAlert(state: $state)
            // TODO inject somwhere else?
            .environment(\.defaultErrorDescription, .init("UP_LOGIN_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            .onTapGesture {
                focusedField = nil
            }
    }

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

        // TODO we could emit a debug warning if there was a login request but the
        //  user isn't logged in afterwards?
    }
}

#if DEBUG
struct DefaultUserIdPasswordBasedEmbeddedView_Previews: PreviewProvider {
    static let accountService = MockUsernamePasswordAccountService()

    static var previews: some View {
        NavigationStack {
            UserIdPasswordEmbeddedView(using: accountService)
                .environmentObject(Account(accountService))
        }
    }
}
#endif
