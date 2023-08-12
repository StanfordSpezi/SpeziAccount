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
    /// Provides localization information for the sign up-related views in the Accont module.
    ///
    /// The values passed into the ``Localization`` substructs are automatically interpreted according to the localization key mechanisms defined in the Spezi Views module.
    ///
    /// You can, e.g., only customize a specific value or all values that are available in the ``Localization/SignUp-swift.struct/init(buttonTitle:navigationTitle:username:password:passwordRepeat:passwordNotEqualError:givenName:familyName:genderIdentityTitle:dateOfBirthTitle:signUpActionButtonTitle:defaultSignUpFailedError:)`` initializer.
    ///
    /// ```swift
    /// SignUp(
    ///     navigationTitle: "CUSTOM_NAVIGATION_TITLE",
    ///     username: FieldLocalizationResource(
    ///        title: "CUSTOM_USERNAME",
    ///        placeholder: "CUSTOM_USERNAME_PLACEHOLDER"
    ///     )
    /// )
    /// ```
    public struct SignUp: Codable {
        /// A default configuration for providing localized text to sign up views.
        public static let `default` = SignUp(
            buttonTitle: LocalizedStringResource("UAP_SIGNUP_BUTTION_TITLE", bundle: .atURL(from: .module)),
            navigationTitle: LocalizedStringResource("UAP_SIGNUP_NAVIGATION_TITLE", bundle: .atURL(from: .module)),
            username: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_SIGNUP_USERNAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_SIGNUP_USERNAME_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            password: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_SIGNUP_PASSWORD_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_SIGNUP_PASSWORD_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            passwordRepeat: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_SIGNUP_PASSWORD_REPEAT_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_SIGNUP_PASSWORD_REPEAT_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            passwordNotEqualError: LocalizedStringResource("UAP_SIGNUP_PASSWORD_NOT_EQUAL_ERROR", bundle: .atURL(from: .module)),
            givenName: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_SIGNUP_GIVEN_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            familyName: FieldLocalizationResource(
                title: LocalizedStringResource("UAP_SIGNUP_FAMILY_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            ),
            genderIdentityTitle: LocalizedStringResource("UAP_SIGNUP_GENDER_IDENTITY_TITLE", bundle: .atURL(from: .module)),
            dateOfBirthTitle: LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .atURL(from: .module)),
            signUpActionButtonTitle: LocalizedStringResource("UAP_SIGNUP_ACTION_BUTTON_TITLE", bundle: .atURL(from: .module)),
            defaultSignUpFailedError: LocalizedStringResource("UAP_SIGNUP_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module))
        )
        
        
        /// A localized `LocalizedStringResource` to display on the sign up button.
        public let buttonTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` for sign up view's localized navigation title.
        public let navigationTitle: LocalizedStringResource
        /// A `FieldLocalizationResource` instance containing the localized title and placeholder text for the username field.
        public let username: FieldLocalizationResource
        /// A  `FieldLocalizationResource` instance containing the localized title and placeholder text for the password field.
        public let password: FieldLocalizationResource
        /// A  `FieldLocalizationResource` instance containing the localized title and placeholder text for the password repeat field.
        public let passwordRepeat: FieldLocalizationResource
        /// A localized`LocalizedStringResource` error message to be displayed when the text in the password and password repeat fields are not equal.
        public let passwordNotEqualError: LocalizedStringResource
        /// A `FieldLocalizationResource` instance containing the localized title and placeholder text for the given name (first name) field.
        public let givenName: FieldLocalizationResource
        /// A `FieldLocalizationResource` instance containing the localized title and placeholder text for the family name (last name) field.
        public let familyName: FieldLocalizationResource
        /// A localized `LocalizedStringResource` label for the gender identity field.
        public let genderIdentityTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` label for the date of birth field.
        public let dateOfBirthTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` title for the sign up action button.
        public let signUpActionButtonTitle: LocalizedStringResource
        /// A localized `LocalizedStringResource` message to display when sign up fails.
        public let defaultSignUpFailedError: LocalizedStringResource
        
        
        /// Creates a localization configuration for signup views.
        ///
        /// - Parameters:
        ///   - buttonTitle: A localized `LocalizedStringResource` to display on the sign up button.
        ///   - navigationTitle: A localized `LocalizedStringResource` for sign up view's localized navigation title.
        ///   - username: A `FieldLocalizationResource` instance containing the localized title and placeholder text for the username field.
        ///   - password: A  `FieldLocalizationResource` instance containing the localized title and placeholder text for the password field.
        ///   - passwordRepeat: A  `FieldLocalizationResource` instance containing the localized title and placeholder text for the password repeat field.
        ///   - passwordNotEqualError: A localized`LocalizedStringResource` error message to be displayed when the text in the password and password repeat fields are not equal.
        ///   - givenName: A `FieldLocalizationResource` instance containing the localized title and placeholder text for the given name (first name) field.
        ///   - familyName: A `FieldLocalizationResource` instance containing the localized title and placeholder text for the family name (last name) field.
        ///   - genderIdentityTitle: A localized `LocalizedStringResource` label for the gender identity field.
        ///   - dateOfBirthTitle: A localized `LocalizedStringResource` label for the date of birth field.
        ///   - signUpActionButtonTitle: A localized `LocalizedStringResource` title for the sign up action button.
        ///   - defaultSignUpFailedError: A localized `LocalizedStringResource` message to display when sign up fails.
        public init(
            buttonTitle: LocalizedStringResource = SignUp.default.buttonTitle,
            navigationTitle: LocalizedStringResource = SignUp.default.navigationTitle,
            username: FieldLocalizationResource = SignUp.default.username,
            password: FieldLocalizationResource = SignUp.default.password,
            passwordRepeat: FieldLocalizationResource = SignUp.default.passwordRepeat,
            passwordNotEqualError: LocalizedStringResource = SignUp.default.passwordNotEqualError,
            givenName: FieldLocalizationResource = SignUp.default.givenName,
            familyName: FieldLocalizationResource = SignUp.default.familyName,
            genderIdentityTitle: LocalizedStringResource = SignUp.default.genderIdentityTitle,
            dateOfBirthTitle: LocalizedStringResource = SignUp.default.dateOfBirthTitle,
            signUpActionButtonTitle: LocalizedStringResource = SignUp.default.signUpActionButtonTitle,
            defaultSignUpFailedError: LocalizedStringResource = SignUp.default.defaultSignUpFailedError
        ) {
            self.buttonTitle = buttonTitle
            self.navigationTitle = navigationTitle
            self.username = username
            self.password = password
            self.passwordRepeat = passwordRepeat
            self.passwordNotEqualError = passwordNotEqualError
            self.givenName = givenName
            self.familyName = familyName
            self.genderIdentityTitle = genderIdentityTitle
            self.dateOfBirthTitle = dateOfBirthTitle
            self.signUpActionButtonTitle = signUpActionButtonTitle
            self.defaultSignUpFailedError = defaultSignUpFailedError
        }
    }
}
