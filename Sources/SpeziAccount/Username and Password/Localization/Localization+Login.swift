//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews


extension Localization {
    /// Provides localization information for the login-related views in the Account module.
    ///
    /// The values passed into the ``Localization`` substructs are automatically interpreted according to the localization key mechanisms defined in the Spezi Views module.
    ///
    /// You can, e.g., only customize a specific value or all values that are available in the ``Localization/Login-swift.struct/init(buttonTitle:navigationTitle:username:password:loginActionButtonTitle:defaultLoginFailedError:)`` initializer.
    ///
    /// ```swift
    /// Login(
    ///     navigationTitle: "CUSTOM_NAVIGATION_TITLE",
    ///     username: FieldLocalization(
    ///        title: "CUSTOM_USERNAME",
    ///        placeholder: "CUSTOM_USERNAME_PLACEHOLDER"
    ///     )
    /// )
    /// ```
    public struct Login: Codable {
        /// A default configuration for providing localized text to login views.
        public static let `default` = Login(
            buttonTitle: LocalizedStringResource("UAP_LOGIN_BUTTON_TITLE", bundle: .atURL(from: .module)),
            navigationTitle: LocalizedStringResource("UAP_LOGIN_NAVIGATION_TITLE", bundle: .atURL(from: .module)),
            username: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_LOGIN_USERNAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_LOGIN_USERNAME_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            password: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_LOGIN_PASSWORD_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_LOGIN_PASSWORD_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            loginActionButtonTitle: LocalizedStringResource("UAP_LOGIN_ACTION_BUTTON_TITLE", bundle: .atURL(from: .module)),
            defaultLoginFailedError: LocalizedStringResource("UAP_LOGIN_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module))
        )
        
        
        /// A localized `LocalizedStringResource` to display on the login button.
        public let buttonTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` for login view's navigation title.
        public let navigationTitle: LocalizedStringResource
        /// A `FieldLocalization` instance containing the localized title and placeholder text for the username field.
        public let username: FieldLocalizationResource
        /// A  `FieldLocalization` instance containing the localized title and placeholder text for the password field.
        public let password: FieldLocalizationResource
        /// A localized `LocalizedStringResource` to display on the login action button.
        public let loginActionButtonTitle: LocalizedStringResource
        /// A localized`LocalizedStringResource` error message to be displayed when login fails.
        public let defaultLoginFailedError: LocalizedStringResource
        
        
        /// Creates a localization configuration for login views.
        ///
        /// - Parameters:
        ///   - buttonTitle: A localized `LocalizedStringResource` to display on the login button.
        ///   - navigationTitle: A localized `LocalizedStringResource` for the login view's navigation title.
        ///   - username: A `FieldLocalization` instance containing the localized title and placeholder text for the username field.
        ///   - password: A `FieldLocalization` instance containing the localized title and placeholder text for the password field.
        ///   - loginActionButtonTitle: A localized `LocalizedStringResource` to display on the login action button.
        ///   - defaultLoginFailedError: A localized `LocalizedStringResource` error message to be displayed when login fails.
        public init(
            buttonTitle: LocalizedStringResource = Login.default.buttonTitle,
            navigationTitle: LocalizedStringResource = Login.default.navigationTitle,
            username: FieldLocalizationResource = Login.default.username,
            password: FieldLocalizationResource = Login.default.password,
            loginActionButtonTitle: LocalizedStringResource = Login.default.loginActionButtonTitle,
            defaultLoginFailedError: LocalizedStringResource = Login.default.defaultLoginFailedError
        ) {
            self.buttonTitle = buttonTitle
            self.navigationTitle = navigationTitle
            self.username = username
            self.password = password
            self.loginActionButtonTitle = loginActionButtonTitle
            self.defaultLoginFailedError = defaultLoginFailedError
        }
    }
}
