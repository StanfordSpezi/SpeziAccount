//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public class AccountValueStorageBuilder<Container: AccountValueStorageContainer> {
    var storage: AccountValueStorage


    public init() {
        self.storage = .init()
    }

    init(from storage: AccountValueStorage) {
        self.storage = storage
    }

    public convenience init<Source: AccountValueStorageContainer>(from storage: Source) {
        // TODO might just remove them? to avoid anti-patterns?
        self.init(from: storage.storage)
    }


    @discardableResult
    public func set<Key: RequiredAccountValueKey>(_ key: Key.Type, value: Key.Value) -> Self {
        storage[Key.self] = value
        return self
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        storage[Key.self] = value
        return self
    }

    @discardableResult
    public func set<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) -> Self {
        set(Key.self, value: value)
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) -> Self {
        set(Key.self, value: value)
    }

    @discardableResult
    public func remove<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> Self {
        storage[Key.self] = nil
        return self
    }
}
