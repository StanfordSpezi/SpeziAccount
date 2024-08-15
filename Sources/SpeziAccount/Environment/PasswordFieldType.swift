//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The semantic use of a password field.
public enum PasswordFieldType {
    /// Standard password field
    case password
    /// New password field
    case new
    /// Password repeat field
    case `repeat`
}


extension PasswordFieldType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .password:
            return AccountKeys.password.name
        case .new:
            return .init("NEW_PASSWORD", bundle: .atURL(from: .module))
        case .repeat:
            return .init("REPEAT_PASSWORD", bundle: .atURL(from: .module))
        }
    }

    public var localizedPrompt: LocalizedStringResource {
        switch self {
        case .password:
            return AccountKeys.password.name
        case .new:
            return .init("NEW_PASSWORD_PROMPT", bundle: .atURL(from: .module))
        case .repeat:
            return .init("REPEAT_PASSWORD_PROMPT", bundle: .atURL(from: .module))
        }
    }
}


extension PasswordFieldType: Sendable, Hashable {}


extension EnvironmentValues {
    private struct PasswordFieldTypeKey: EnvironmentKey {
        static let defaultValue: PasswordFieldType = .password
    }

    /// The semantic use of a password field.
    ///
    /// ## Topics
    ///
    /// - ``PasswordFieldType``
    public var passwordFieldType: PasswordFieldType {
        get {
            self[PasswordFieldTypeKey.self]
        }
        set {
            self[PasswordFieldTypeKey.self] = newValue
        }
    }
}
