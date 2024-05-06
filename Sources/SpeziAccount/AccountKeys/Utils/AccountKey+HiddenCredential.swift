//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AccountValues

extension AccountKey {
    /// A ``AccountKeyCategory/credentials`` key that is not meant to be modified in
    /// the `SecurityOverview` section in the ``AccountOverview``.
    static var isHiddenCredential: Bool {
        self == AccountIdKey.self || self == UserIdKey.self
    }
}
