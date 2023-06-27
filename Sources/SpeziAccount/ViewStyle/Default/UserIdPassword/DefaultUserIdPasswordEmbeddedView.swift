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

// TODO place it somewhere else! (Model?)
enum TextFieldConfiguration {
    case username
    case emailAddress
    case password
    case newPassword
    case custom(textContent: UITextContentType?, keyboard: UIKeyboardType = .default)

    var textContentType: UITextContentType? {
        switch self {
        case .username:
            return .username
        case .emailAddress:
            return .emailAddress
        case .password:
            return .password
        case .newPassword:
            return .newPassword
        case let .custom(textContent, _):
            return textContent
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .emailAddress:
            return .emailAddress
        case let .custom(_, keyboard):
            return keyboard
        case .username, .password, .newPassword:
            return .default
        }
    }
}

struct DefaultUserIdPasswordEmbeddedView<Service: UserIdPasswordAccountService>: View {
    var service: Service

    // TODO this is client side stuff!! this limitations must be on the server side, don't encourage it!
    // TODO this is all configuration!
    private let idValidationRules: [ValidationRule]
    private let passwordValidationRules: [ValidationRule]
    private let localization: ConfigurableLocalization<Localization.Login>

    private let idFieldConfiguration: TextFieldConfiguration
    private let passwordFieldConfiguration: TextFieldConfiguration

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
    private var idEmpty = false
    @State
    private var passwordEmpty = false

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
                    TextField(text: $userId) {
                        Text("E-Mail Address or Username")
                    }
                        .keyboardType(idFieldConfiguration.keyboardType)
                        .textContentType(idFieldConfiguration.textContentType)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .username)
                    if idEmpty {
                        HStack {
                            Text("E-Mail Address cannot be empty!")
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding([.leading, .bottom], 8)
                            Spacer()
                        }
                    }
                    SecureField("Password", text: $password)
                        .keyboardType(passwordFieldConfiguration.keyboardType)
                        .textContentType(passwordFieldConfiguration.textContentType)
                        .onTapFocus(focusedField: _focusedField, fieldIdentifier: .password)
                }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
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


                HStack {
                    if passwordEmpty {
                        Text("Password cannot be empty!")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding([.leading, .bottom], 8)
                    }
                    Spacer()
                    NavigationLink {
                        service.viewStyle.makePasswordResetView()
                    } label: {
                        Text("Forgot Password?") // TODO localize
                            .font(.caption)
                            .bold()
                            .foregroundColor(Color(uiColor: .systemGray)) // TODO color primary? secondary?
                    }
                }
            }
                .padding(.vertical, 0)

            Button(action: loginButtonAction) {
                Text("Login") // TODO localize
                    .frame(maxWidth: .infinity, minHeight: 38) // TODO minHeight? vs padding(6)?
                    .replaceWithProcessingIndicator(ifProcessing: state)
            }
                .buttonStyle(.borderedProminent)
                .disabled(state == .processing)
                .padding(.bottom, 12)
                .padding(.top)


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
                idEmpty = false
                passwordEmpty = false
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
        idFieldConfiguration: TextFieldConfiguration = .emailAddress,
        passwordFieldConfiguration: TextFieldConfiguration = .password,
        localization: ConfigurableLocalization<Localization.Login> = .environment
    ) {
        self.service = service
        self.idValidationRules = idValidationRules
        self.passwordValidationRules = passwordValidationRules
        self.idFieldConfiguration = idFieldConfiguration
        self.passwordFieldConfiguration = passwordFieldConfiguration
        self.localization = localization
    }

    private func loginButtonAction() {
        guard state != .processing else {
            return
        }

        // TODO abstract those checks over the validation rules!
        idEmpty = userId.isEmpty
        passwordEmpty = password.isEmpty

        if idEmpty || passwordEmpty {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            focusedField = .none
            state = .processing
        }

        loginTask = Task {
            do {
                try await service.login(key: userId, password: password)
                withAnimation(.easeIn(duration: 0.2)) {
                    state = .idle
                }
            } catch {
                state = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: "DEFAULT ERROR!" // TODO localize!
                ))
            }
        }
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
