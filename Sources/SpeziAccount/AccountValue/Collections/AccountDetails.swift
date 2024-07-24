//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountKey`` for a list of bundled keys.
public struct AccountDetails: Sendable, AccountValues {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise

    public private(set) var storage: AccountStorage


    public init(from storage: AccountStorage) {
        var storage = consume storage
        if storage.contains(PasswordKey.self) {
            // patch the storage to make sure we make sure to not expose the plaintext password
            storage[PasswordKey.self] = nil
        }
        self.storage = storage
    }

    mutating func patchAccountServiceConfiguration(_ configuration: AccountServiceConfiguration) {
        storage[AccountServiceConfigurationDetailsKey.self] = configuration
    }

    mutating func patchIsNewUser(_ isNewUser: Bool) {
        storage[IsNewUserKey.self] = isNewUser
    }
}
