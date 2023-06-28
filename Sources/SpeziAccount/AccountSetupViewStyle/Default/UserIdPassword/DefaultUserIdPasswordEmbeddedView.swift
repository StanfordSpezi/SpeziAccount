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

struct DefaultUserIdPasswordEmbeddedView<Service: UserIdPasswordAccountService>: View {
    private let service: Service

    // TODO this is client side stuff!! this limitations must be on the server side, don't encourage it!
    // TODO this is all configuration!
    private let idValidationRules: [ValidationRule]
    private let passwordValidationRules: [ValidationRule]
    private let localization: ConfigurableLocalization<Localization.Login> // TODO remove!

    private let idFieldConfiguration: FieldConfiguration
    private let passwordFieldConfiguration: FieldConfiguration

    // TODO we want a view model!
    @State
    private var userId: String = ""
    @State
    private var password: String = ""
    // @State private var valid = false  TODO we don't to validation for the

    @State
    private var state: ViewState = .idle
    @FocusState
    private var focusedField: AccountInputFields?

    @State
    private var userIdValid = false
    @State
    private var passwordValid = false

    @State
    private var loginTask: Task<Void, Error>? {
        willSet {
            loginTask?.cancel()
        }
    }

    @MainActor
    var body: some View {
        VStack {
            VStack {
                // TODO localization (which is implementation dependent!)
                Group {
                    VerifiableTextField(text: $userId, valid: $userIdValid) {
                        Text("E-Mail Address or Username") // TODO localization!
                    }
                        .fieldConfiguration(idFieldConfiguration)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .username)
                        .padding(.bottom, 0.5)

                        // TODO .padding([.leading, .bottom], 8) for the red texts?

                    VerifiableTextField(type: .secure, text: $password, valid: $passwordValid) {
                        Text("Password") // TODO supply LocalizedStringResource before text!
                    } footer: {
                        NavigationLink {
                            service.viewStyle.makePasswordResetView()
                        } label: {
                            Text("Forgot Password?") // TODO localize
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color(uiColor: .systemGray)) // TODO color primary? secondary?
                        }
                    }
                        .fieldConfiguration(passwordFieldConfiguration)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .password)
                }
                    .disableFieldAssistants()
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)/*
                    .onChange(of: userId) { newId in
                        if !newId.isEmpty {
                            idEmpty = false
                        }
                    }
                    .onChange(of: password) { newPassword in
                        if !newPassword.isEmpty {
                            passwordEmpty = false
                        }
                    }
                */
            }
                .padding(.vertical, 0)

            AsyncDataEntrySubmitButton(state: $state, action: loginButtonAction) {
                Text("Login")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
                .padding(.bottom, 12)
                .padding(.top)
                // TODO supply default error description!


            HStack {
                Text("Dont' have an Account yet?") // TODO localize!
                // TODO navigation link
                NavigationLink {
                    service.viewStyle.makeSignupView()
                } label: {
                    Text("Signup") // TODO primary accent color!
                }
                // TODO .padding(.horizontal, 0)
            }
                .font(.footnote)
        }
            // TODO a "keep user" modifier?
            .navigationBarBackButtonHidden(state == .processing)
            .interactiveDismissDisabled(state == .processing)
            .viewStateAlert(state: $state)
            .onTapGesture {
                focusedField = nil // TODO what does this do?
            }
            .onDisappear {
                // TODO reset stuff
                // TODO idEmpty = false
                // TODO passwordEmpty = false
                // TODO loginTask?.cancel()
                //  => app exit?
            }
    }

    /// Instantiate a new `DefaultIdPasswordBasedEmbeddedView` TODO docs
    ///
    /// - Parameters:
    ///   - service: TODO document account service!
    ///   - idValidationRules: A collection of ``ValidationRule``s to validate to the entered user key.
    ///   - passwordValidationRules: A collection of ``ValidationRule``s to validate to the entered password.
    ///   - idFieldConfiguration: TODO docs
    ///   - passwordFieldConfiguration: TODO docs
    ///   - localization: A ``ConfigurableLocalization`` to define the localization of this view.
    ///      The default value uses the localization provided by the ``UsernamePasswordAccountService`` provided in the SwiftUI environment. TODO docs!
    public init(
        using service: Service,
        validatingIdWith idValidationRules: [ValidationRule] = [],
        validatingPasswordWith passwordValidationRules: [ValidationRule] = [],
        idFieldConfiguration: FieldConfiguration = .emailAddress,
        passwordFieldConfiguration: FieldConfiguration = .password,
        localization: ConfigurableLocalization<Localization.Login> = .environment
    ) {
        self.service = service
        self.idValidationRules = idValidationRules
        self.passwordValidationRules = passwordValidationRules
        self.idFieldConfiguration = idFieldConfiguration
        self.passwordFieldConfiguration = passwordFieldConfiguration
        self.localization = localization
    }

    private func loginButtonAction() async throws {
        // TODO verifications are now called after the animation!

        // TODO ensure those are called!
        guard userIdValid && passwordValid else {
            return
        }

        try await service.login(userId: userId, password: password)
    }
}

#if DEBUG
struct DefaultUserIdPasswordBasedEmbeddedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultUserIdPasswordEmbeddedView(using: DefaultUsernamePasswordAccountService())
        }
    }
}
#endif
