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
public struct AccountDetails: Sendable, ModifiableAccountValueStorageContainer {
    public typealias Builder = AccountValueStorageBuilder<Self>

    public var storage: AccountValueStorage // TODO modifieable?

    init<Service: AccountService>(storage: AccountValueStorage, owner accountService: Service) {
        self.storage = storage

        // patch the storage to make sure we make sure to not expose the plaintext password
        self.storage[PasswordAccountValueKey.self] = nil
        self.storage[ActiveAccountServiceKey.self] = accountService
    }


    // TODO move to Account Service? => also we need something for "batch" processing (e.g. Edit View!)
    public func update<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) {
    }

    public func update<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) {
    }
}
