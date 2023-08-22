//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The semantic use of a password field.
public enum PasswordFieldType: EnvironmentKey, CustomLocalizedStringResourceConvertible {
    /// Standard password field
    case password
    /// New password field
    case new
    /// Password repeat field
    case `repeat`


    public static let defaultValue: PasswordFieldType = .password


    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .password:
            return PasswordKey.name
        case .new:
            return .init("NEW_PASSWORD", bundle: .atURL(from: .module))
        case .repeat:
            return .init("REPEAT_PASSWORD", bundle: .atURL(from: .module))
        }
    }
}


extension EnvironmentValues {
    /// The semantic use of a password field.
    public var passwordFieldType: PasswordFieldType {
        get {
            self[PasswordFieldType.self]
        }
        set {
            self[PasswordFieldType.self] = newValue
        }
    }
}
