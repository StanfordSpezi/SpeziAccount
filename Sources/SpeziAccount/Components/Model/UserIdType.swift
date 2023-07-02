//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum UserIdType {
    case emailAddress
    case username
    case custom(_ label: LocalizedStringResource)
}

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
