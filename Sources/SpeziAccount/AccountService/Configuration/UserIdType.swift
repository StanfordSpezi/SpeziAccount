//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Determines the type and kind of the `userId`.
///
/// Refer to the documentation of ``AccountDetails/userId``.
public enum UserIdType {
    /// An user id that is the user's email address at the same time.
    case emailAddress
    /// An user id that models as some kind of alphanumeric string.
    case username
    /// An user id that has some custom representation with unspecified semantics.
    ///
    /// The `LocalizedStringResource` is used as the textual representation of this id type.
    case custom(_ label: LocalizedStringResource)
}


extension UserIdType: Equatable, Sendable {}


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
