//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public class AccountValueStorageBuilder<Container: AccountValueStorageContainer> {
    private var storage: AccountValueStorage

    public init() {
        self.storage = .init()
    }

    public init<Source: AccountValueStorageContainer>(from storage: Source) {
        // TODO might just remove them? to avoid anti-patterns?
        self.storage = storage.storage
    }

    @discardableResult
    public func add<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) -> Self {
        storage[Key.self] = value
        return self
    }

    @discardableResult
    public func add<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) -> Self {
        storage[Key.self] = value
        return self
    }

    @discardableResult
    public func remove<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> Self {
        storage[Key.self] = nil
        return self
    }

    @discardableResult
    public func add<Key: AccountValueKey>(
        _ keyPath: KeyPath<AccountValueKeys, Key.Type>,
        value: @autoclosure () -> Key.Value,
        ifConfigured requirements: AccountValueRequirements
    ) -> Self {
        if requirements.configured(Key.self) {
            return add(keyPath, value: value())
        }
        return self
    }
}


extension AccountValueStorageBuilder where Container == AccountDetails {
    public func build<Service: AccountService>(owner accountService: Service) -> Container {
        Container(storage: self.storage, owner: accountService)
    }
}


extension AccountValueStorageBuilder where Container == SignupRequest {
    public func build(
        checking requirements: AccountValueRequirements? = nil
    ) throws -> Container {
        let request = Container(storage: self.storage)

        if let requirements {
            try requirements.validateRequirements(in: request)
        }

        return request
    }
}
