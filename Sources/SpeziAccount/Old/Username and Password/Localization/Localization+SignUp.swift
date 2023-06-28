//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
    ///     username: FieldLocalization(
    ///        title: "CUSTOM_USERNAME",
    ///        placeholder: "CUSTOM_USERNAME_PLACEHOLDER"
    ///     )
    /// )
    /// ```
    public struct SignUp: Codable {
        /// A default configuration for providing localized text to sign up views.
        public static let `default` = SignUp(
            buttonTitle: String(moduleLocalized: "UAP_SIGNUP_BUTTON_TITLE"),
            navigationTitle: String(moduleLocalized: "UAP_SIGNUP_NAVIGATION_TITLE"),
            username: FieldLocalizationResource(
                title: "UAP_SIGNUP_USERNAME_TITLE",
                placeholder: "UAP_SIGNUP_USERNAME_PLACEHOLDER",
                bundle: .module
            ),
            password: FieldLocalizationResource(
                title: "UAP_SIGNUP_PASSWORD_TITLE",
                placeholder: "UAP_SIGNUP_PASSWORD_PLACEHOLDER",
                bundle: .module
            ),
            passwordRepeat: FieldLocalizationResource(
                title: "UAP_SIGNUP_PASSWORD_REPEAT_TITLE",
                placeholder: "UAP_SIGNUP_PASSWORD_REPEAT_PLACEHOLDER",
                bundle: .module
            ),
            passwordNotEqualError: String(moduleLocalized: "UAP_SIGNUP_PASSWORD_NOT_EQUAL_ERROR"),
            givenName: FieldLocalizationResource(
                title: "UAP_SIGNUP_GIVEN_NAME_TITLE",
                placeholder: "UAP_SIGNUP_GIVEN_NAME_PLACEHOLDER",
                bundle: .module
            ),
            familyName: FieldLocalizationResource(
                title: "UAP_SIGNUP_FAMILY_NAME_TITLE",
                placeholder: "UAP_SIGNUP_FAMILY_NAME_PLACEHOLDER",
                bundle: .module
            ),
            genderIdentityTitle: String(moduleLocalized: "UAP_SIGNUP_GENDER_IDENTITY_TITLE"),
            dateOfBirthTitle: String(moduleLocalized: "UAP_SIGNUP_DATE_OF_BIRTH_TITLE"),
            signUpActionButtonTitle: String(moduleLocalized: "UAP_SIGNUP_ACTION_BUTTON_TITLE"),
            defaultSignUpFailedError: String(moduleLocalized: "UAP_SIGNUP_FAILED_DEFAULT_ERROR")
        )
        
        
        /// A localized `String` to display on the sign up button.
        public let buttonTitle: String
        /// A localized `String` for sign up view's localized navigation title.
        public let navigationTitle: String
        /// A `FieldLocalization` instance containing the localized title and placeholder text for the username field.
        public let username: FieldLocalizationResource
        /// A  `FieldLocalization` instance containing the localized title and placeholder text for the password field.
        public let password: FieldLocalizationResource
        /// A  `FieldLocalization` instance containing the localized title and placeholder text for the password repeat field.
        public let passwordRepeat: FieldLocalizationResource
        /// A localized`String` error message to be displayed when the text in the password and password repeat fields are not equal.
        public let passwordNotEqualError: String
        /// A `FieldLocalization` instance containing the localized title and placeholder text for the given name (first name) field.
        public let givenName: FieldLocalizationResource
        /// A `FieldLocalization` instance containing the localized title and placeholder text for the family name (last name) field.
        public let familyName: FieldLocalizationResource
        /// A localized `String` label for the gender identity field.
        public let genderIdentityTitle: String
        /// A localized `String` label for the date of birth field.
        public let dateOfBirthTitle: String
        /// A localized `String` title for the sign up action button.
        public let signUpActionButtonTitle: String
        /// A localized `String` message to display when sign up fails.
        public let defaultSignUpFailedError: String
        
        
        /// Creates a localization configuration for signup views.
        ///
        /// - Parameters:
        ///   - buttonTitle: A localized `String` to display on the sign up button.
        ///   - navigationTitle: A localized `String` for sign up view's localized navigation title.
        ///   - username: A `FieldLocalization` instance containing the localized title and placeholder text for the username field.
        ///   - password: A  `FieldLocalization` instance containing the localized title and placeholder text for the password field.
        ///   - passwordRepeat: A  `FieldLocalization` instance containing the localized title and placeholder text for the password repeat field.
        ///   - passwordNotEqualError: A localized`String` error message to be displayed when the text in the password and password repeat fields are not equal.
        ///   - givenName: A `FieldLocalization` instance containing the localized title and placeholder text for the given name (first name) field.
        ///   - familyName: A `FieldLocalization` instance containing the localized title and placeholder text for the family name (last name) field.
        ///   - genderIdentityTitle: A localized `String` label for the gender identity field.
        ///   - dateOfBirthTitle: A localized `String` label for the date of birth field.
        ///   - signUpActionButtonTitle: A localized `String` title for the sign up action button.
        ///   - defaultSignUpFailedError: A localized `String` message to display when sign up fails.
        public init(
            buttonTitle: String = SignUp.default.buttonTitle,
            navigationTitle: String = SignUp.default.navigationTitle,
            username: FieldLocalizationResource = SignUp.default.username,
            password: FieldLocalizationResource = SignUp.default.password,
            passwordRepeat: FieldLocalizationResource = SignUp.default.passwordRepeat,
            passwordNotEqualError: String = SignUp.default.passwordNotEqualError,
            givenName: FieldLocalizationResource = SignUp.default.givenName,
            familyName: FieldLocalizationResource = SignUp.default.familyName,
            genderIdentityTitle: String = SignUp.default.genderIdentityTitle,
            dateOfBirthTitle: String = SignUp.default.dateOfBirthTitle,
            signUpActionButtonTitle: String = SignUp.default.signUpActionButtonTitle,
            defaultSignUpFailedError: String = SignUp.default.defaultSignUpFailedError
        ) {
            self.buttonTitle = buttonTitle.localized.localizedString()
            self.navigationTitle = navigationTitle.localized.localizedString()
            self.username = username
            self.password = password
            self.passwordRepeat = passwordRepeat
            self.passwordNotEqualError = passwordNotEqualError.localized.localizedString()
            self.givenName = givenName
            self.familyName = familyName
            self.genderIdentityTitle = genderIdentityTitle.localized.localizedString()
            self.dateOfBirthTitle = dateOfBirthTitle.localized.localizedString()
            self.signUpActionButtonTitle = signUpActionButtonTitle.localized.localizedString()
            self.defaultSignUpFailedError = defaultSignUpFailedError.localized.localizedString()
        }
    }
}
