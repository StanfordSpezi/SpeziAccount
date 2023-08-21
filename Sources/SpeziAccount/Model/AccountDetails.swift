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
    public let storage: AccountValueStorage


    public init(from storage: AccountValueStorage) {
        self.storage = storage
        precondition(storage[ActiveAccountServiceKey.self] != nil, "Direct init access failed to supply ActiveAccountServiceKey")
    }


    fileprivate init<Service: AccountService>(from storage: AccountValueStorage, owner accountService: Service) {
        var storage = storage

        // patch the storage to make sure we make sure to not expose the plaintext password
        storage[PasswordKey.self] = nil
        storage[ActiveAccountServiceKey.self] = accountService
        self.init(from: storage)
    }
}


extension AccountValueStorageBuilder where Container == AccountDetails {
    public func build<Service: AccountService>(owner accountService: Service) -> Container {
        AccountDetails(from: self.storage, owner: accountService)
    }
}
