//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import RegexBuilder
import Spezi
import SpeziViews
import SwiftUI

/// Account service that enables a email and password based account management.
///
/// The ``EmailPasswordAccountService`` enables a email and password based account management based on the ``UsernamePasswordAccountService``.
///
/// Other ``AccountService``s can be created by subclassing the ``EmailPasswordAccountService`` and overriding the ``EmailPasswordAccountService/localization``,
/// buttons like the ``EmailPasswordAccountService/loginButton``, or overriding  the ``EmailPasswordAccountService/button(_:destination:)`` function.
open class EmailPasswordAccountService: UsernamePasswordAccountService {
    override open var localization: Localization {
        let usernameField = FieldLocalizationResource(
            title: "EAP_LOGIN_USERNAME_TITLE",
            placeholder: "EAP_LOGIN_USERNAME_PLACEHOLDER",
            bundle: .module
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
                usernameValidationRules: [.minimalEmailValidationRule]
            )
        )
    }
    
    override open var signUpButton: AnyView {
        button(
            localization.signUp.buttonTitle,
            destination: UsernamePasswordSignUpView(
                usernameValidationRules: [.minimalEmailValidationRule]
            )
        )
    }
    
    override open var resetPasswordButton: AnyView {
        AnyView(
            NavigationLink {
                UsernamePasswordResetPasswordView(
                    usernameValidationRules: [.minimalEmailValidationRule]
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
                Group {
                    Image(systemName: "envelope.fill")
                        .font(.title2)
                    Text(title)
                }
                    .accountServiceButtonBackground()
            }
        )
    }
}
