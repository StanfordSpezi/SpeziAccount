//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// The user id configuration of an ``AccountService``.
///
/// This configuration comes with the assumption that every ``AccountService`` exposes some sort of primary and unique user identifier.
/// UI components may use this configuration to get more information about the shape of such a user identifier
/// (e.g. if it's an email address or just some alphanumerical string).
///
/// Access the configuration via the ``AccountServiceConfiguration/userIdConfiguration`` property.
public struct UserIdConfiguration: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static var defaultValue: UserIdConfiguration {
        UserIdConfiguration(type: .emailAddress, contentType: .username, keyboardType: .emailAddress)
    }

    /// The type of user id stored in ``UserIdKey``.
    /// You can use this property to provide a localized textual representation of the user id.
    public let idType: UserIdType
    /// The `UITextContentType` used for a field that is used to input the user id.
    ///
    /// - Note: Even if the user id is an email address you will want to use `UITextContentType/username` and set
    ///     the ``keyboardType`` to `UIKeyboardType/emailAddress`. For more information refer to
    ///     [Enabling Password AutoFill on a text input view](https://developer.apple.com/documentation/security/password_autofill/enabling_password_autofill_on_a_text_input_view).
    public let textContentType: UITextContentType?
    /// The `UIKeyboardType` used for a field that is used to input the user id.
    public let keyboardType: UIKeyboardType

    /// Initialize a new `UserIdConfiguration`.
    /// - Parameters:
    ///   - type: The user id type.
    ///   - contentType: The `UITextContentType` used for a field that is used to input the user id.
    ///   - keyboardType: The `UIKeyboardType` used for a field that is used to input the user id.
    public init(type: UserIdType, contentType: UITextContentType? = .username, keyboardType: UIKeyboardType = .default) {
        self.idType = type
        self.textContentType = contentType
        self.keyboardType = keyboardType
    }
}


extension AccountServiceConfiguration {
    /// Access the user id configuration of an ``AccountService``.
    public var userIdConfiguration: UserIdConfiguration {
        storage[UserIdConfiguration.self]
    }
}
