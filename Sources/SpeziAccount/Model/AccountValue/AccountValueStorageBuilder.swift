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

    init(from storage: AccountValueStorage) {
        self.storage = storage // TODO make this public?
    }

    public convenience init<Source: AccountValueStorageContainer>(from storage: Source) {
        // TODO might just remove them? to avoid anti-patterns?
        self.init(from: storage.storage)
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

    // TODO this method can be removed!
    @discardableResult
    public func add<Key: AccountValueKey>(
        _ keyPath: KeyPath<AccountValueKeys, Key.Type>,
        value: @autoclosure () -> Key.Value,
        ifConfigured requirements: AccountValueRequirements
    ) -> Self {
        if requirements.configured(keyPath) {
            return add(keyPath, value: value())
        }
        return self
    }
}


extension AccountValueStorageBuilder where Container == AccountDetails {
    public func build<Service: AccountService>(owner accountService: Service) -> Container {
        AccountDetails(storage: self.storage, owner: accountService)
    }
}


extension AccountValueStorageBuilder where Container == SignupRequest {
    public func build(
        checking requirements: AccountValueRequirements? = nil
    ) throws -> Container {
        let request = SignupRequest(storage: self.storage)

        if let requirements {
            try requirements.validateRequirements(in: request)
        }

        return request
    }
}
