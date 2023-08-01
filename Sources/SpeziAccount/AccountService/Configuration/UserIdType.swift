//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Determines the type and kind of the ``UserIdKey``.
///
/// TODO discuss how to set this setting?
public enum UserIdType: Sendable, Equatable {
    /// The user id is the user's email address at the same time.
    case emailAddress
    /// The user id is modeled as some kind of alphanumeric string.
    case username
    /// The user id has some custom representation with unspecified semantics.
    /// TODO document label!
    case custom(_ label: LocalizedStringResource)
}


extension LocalizedStringResource: @unchecked Sendable {} // TODO not ideal!

extension UserIdType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emailAddress:
            return LocalizedStringResource("USER_ID_EMAIL", bundle: .atURL(from: .module))
        case .username:
            return LocalizedStringResource("USER_ID_USERNAME", bundle: .atURL(from: .module))
        case let .custom(label):
            return label
        }
    }
}
