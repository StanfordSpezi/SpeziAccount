//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public enum FieldConfiguration {
    case username
    case emailAddress
    case password
    case newPassword
    case custom(textContent: UITextContentType? = nil, keyboard: UIKeyboardType = .default)

    public var textContentType: UITextContentType? {
        switch self {
        case .username:
            return .username
        case .emailAddress:
            // we control email address behavior using the keyboard type
            // see https://developer.apple.com/documentation/security/password_autofill/enabling_password_autofill_on_a_text_input_view
            return .username
        case .password:
            return .password
        case .newPassword:
            return .newPassword
        case let .custom(textContent, _):
            return textContent
        }
    }

    public var keyboardType: UIKeyboardType {
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
