//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import RegexBuilder
import SwiftUI
import Views


/// Account service that enables a email and password based account management.
///
/// The ``EmailPasswordAccountService`` enables a email and password based account management based on the ``UsernamePasswordAccountService``.
///
/// Other ``AccountService``s can be created by subclassing the ``EmailPasswordAccountService`` and overriding the ``EmailPasswordAccountService/localization``,
/// buttons like the ``EmailPasswordAccountService/loginButton``, or overriding  the ``EmailPasswordAccountService/button(_:destination:)`` function.
open class EmailPasswordAccountService: UsernamePasswordAccountService {
    public var emailValidationRule: ValidationRule {
        guard let regex = try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") else {
            fatalError("Invalid E-Mail Regex in the EmailPasswordAccountService")
        }
        
        return ValidationRule(
            regex: regex,
            message: String(localized: "EAP_EMAIL_VERIFICATION_ERROR", bundle: .module)
        )
    }
    
    override open var localization: Localization {
        let usernameField = FieldLocalization(
            title: String(moduleLocalized: "EAP_LOGIN_USERNAME_TITLE"),
            placeholder: String(moduleLocalized: "EAP_LOGIN_USERNAME_PLACEHOLDER")
        )
        return Localization(
            login: .init(buttonTitle: String(moduleLocalized: "EAP_LOGIN_BUTTON_TITLE"), username: usernameField),
            signUp: .init(buttonTitle: String(moduleLocalized: "EAP_SIGNUP_BUTTON_TITLE"), username: usernameField),
            resetPassword: .init(username: usernameField)
        )
    }
    
    override open var loginButton: AnyView {
        button(
            localization.login.buttonTitle,
            destination: UsernamePasswordLoginView(
                usernameValidationRules: [emailValidationRule]
            )
        )
    }
    
    override open var signUpButton: AnyView {
        button(
            localization.signUp.buttonTitle,
            destination: UsernamePasswordSignUpView(
                usernameValidationRules: [emailValidationRule]
            )
        )
    }
    
    override open var resetPasswordButton: AnyView {
        AnyView(
            NavigationLink {
                UsernamePasswordResetPasswordView(
                    usernameValidationRules: [emailValidationRule]
                ) {
                    processSuccessfulResetPasswordView
                }
                    .environmentObject(self as UsernamePasswordAccountService)
            } label: {
                Text(localization.resetPassword.buttonTitle)
            }
        )
    }
    
    
    override open func button<V: View>(_ title: String, destination: V) -> AnyView {
        AnyView(
            NavigationLink {
                destination
                    .environmentObject(self as UsernamePasswordAccountService)
            } label: {
                AccountServiceButton {
                    Image(systemName: "envelope.fill")
                        .font(.title2)
                    Text(title)
                }
            }
        )
    }
}
