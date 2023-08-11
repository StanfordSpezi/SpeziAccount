//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountValueKey`` for a list of bundled `AccountValueKey`s.
/// TODO docs on how to build?
public struct AccountDetails: Sendable, AccountValueStorageContainer {
    public typealias Builder = AccountValueStorageBuilder<Self>

    public let storage: AccountValueStorage


    init<Service: AccountService>(storage: AccountValueStorage, owner accountService: Service) {
        var storage = storage

        // patch the storage to make sure we make sure to not expose the plaintext password
        storage[PasswordKey.self] = nil
        storage[ActiveAccountServiceKey.self] = accountService
        self.storage = storage
    }
}


extension AccountValueStorageBuilder where Container == AccountDetails {
    public func build<Service: AccountService>(owner accountService: Service) -> Container {
        AccountDetails(storage: self.storage, owner: accountService)
    }
}
