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
    /// Provides localization information for the reset password-related views in the Accont module.
    ///
    /// The values passed into the ``Localization`` substructs are automatically interpreted according to the localization key mechanisms defined in the Spezi Views module.
    ///
    /// You can, e.g., only customize a specific value or all values that are available in the ``Localization/ResetPassword-swift.struct/init(buttonTitle:navigationTitle:username:resetPasswordActionButtonTitle:processSuccessfulLabel:defaultResetPasswordFailedError:)`` initializer.
    ///
    /// ```swift
    /// ResetPassword(
    ///     navigationTitle: "CUSTOM_NAVIGATION_TITLE",
    ///     username: FieldLocalizationResource(
    ///        title: "CUSTOM_USERNAME",
    ///        placeholder: "CUSTOM_USERNAME_PLACEHOLDER"
    ///     )
    /// )
    /// ```
    public struct ResetPassword: Codable {
        /// A default configuration for providing localized text to reset password views
        public static let `default` = ResetPassword(
            buttonTitle: LocalizedStringResource("UAP_RESET_PASSWORD_BUTTON_TITLE", bundle: .atURL(from: .module)),
            navigationTitle: LocalizedStringResource("UAP_RESET_PASSWORD_NAVIGATION_TITLE", bundle: .atURL(from: .module)),
            username: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_RESET_PASSWORD_USERNAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_RESET_PASSWORD_USERNAME_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            resetPasswordActionButtonTitle: LocalizedStringResource("UAP_RESET_PASSWORD_ACTION_BUTTON_TITLE", bundle: .atURL(from: .module)),
            processSuccessfulLabel: LocalizedStringResource("UAP_RESET_PASSWORD_PROCESS_SUCCESSFUL_LABEL", bundle: .atURL(from: .module)),
            defaultResetPasswordFailedError: LocalizedStringResource("UAP_RESET_PASSWORD_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module))
        )
        
        
        /// A localized `LocalizedStringResource` to display on the reset password button.
        public let buttonTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` for the reset password view's navigation title.
        public let navigationTitle: LocalizedStringResource
        /// A `FieldLocalizationResource` instance containing the localized title and placeholder text for the username field.
        public let username: FieldLocalizationResource
        /// A localized `LocalizedStringResource` to display on the reset password action button.
        public let resetPasswordActionButtonTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` to display when the reset password process has been successful.
        public let processSuccessfulLabel: LocalizedStringResource
        /// A localized `LocalizedStringResource` to display when the reset password process has failed.
        public let defaultResetPasswordFailedError: LocalizedStringResource
        
        
        /// Creates a localization configuration for reset password views.
        ///
        /// - Parameters:
        ///   - buttonTitle: A localized `LocalizedStringResource` title for the reset password button.
        ///   - navigationTitle: A localized `LocalizedStringResource` for the reset password view's navigation title.
        ///   - username: A `FieldLocalizationResource` instance containing the localized title and placeholder text for the username field.
        ///   - resetPasswordActionbuttonTitle: A localized `LocalizedStringResource` to display on the reset password action button.
        ///   - processSuccessfulLabel: A localized `LocalizedStringResource` to display when the reset password process has been successful.
        ///   - defaultResetPasswordFailedError: A localized `LocalizedStringResource` to display when the reset password process has failed.
        public init(
            buttonTitle: LocalizedStringResource = ResetPassword.default.buttonTitle,
            navigationTitle: LocalizedStringResource = ResetPassword.default.navigationTitle,
            username: FieldLocalizationResource = ResetPassword.default.username,
            resetPasswordActionButtonTitle: LocalizedStringResource = ResetPassword.default.resetPasswordActionButtonTitle,
            processSuccessfulLabel: LocalizedStringResource = ResetPassword.default.processSuccessfulLabel,
            defaultResetPasswordFailedError: LocalizedStringResource = ResetPassword.default.defaultResetPasswordFailedError
        ) {
            self.buttonTitle = buttonTitle
            self.navigationTitle = navigationTitle
            self.username = username
            self.resetPasswordActionButtonTitle = resetPasswordActionButtonTitle
            self.processSuccessfulLabel = processSuccessfulLabel
            self.defaultResetPasswordFailedError = defaultResetPasswordFailedError
        }
    }
}
