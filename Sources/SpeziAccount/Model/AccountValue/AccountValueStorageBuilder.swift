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

    /// The count of elements stored in the builder.
    public var count: Int {
        storage.count
    }

    /// Indicates if the builder is empty.
    public var isEmpty: Bool {
        storage.isEmpty
    }


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


    public func clear() {
        storage = .init()
    }

    public func get<Key: AccountValueKey>(_ key: Key.Type) -> Key.Value? {
        storage.get(key)
    }

    @discardableResult
    fileprivate func set0<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value) -> Self {
        storage[Key.self] = value
        return self
    }


    @discardableResult
    public func set<Key: RequiredAccountValueKey>(_ key: Key.Type, value: Key.Value) -> Self {
        set0(key, value: value)
    }

    @discardableResult
    public func set<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value) -> Self {
        set0(Key.self, value: value)
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        if let value {
            return set0(key, value: value)
        }
        return self
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) -> Self {
        set(Key.self, value: value)
    }

    @discardableResult
    public func remove<Key: AccountValueKey>(_ key: Key.Type) -> Self {
        storage[key] = nil
        return self
    }

    @discardableResult
    public func remove<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> Self {
        remove(Key.self)
    }
}

// MARK: - AccountOverview Extensions

extension AccountValueStorageBuilder {
    @discardableResult
    func remove(any accountValue: any AccountValueKey.Type) -> Self {
        accountValue.remove(from: self)
        return self
    }

    @discardableResult
    func setEmptyValue(for accountValue: any AccountValueKey.Type) -> Self {
        accountValue.setEmpty(in: self)
        return self
    }
}

extension AccountValueKey {
    fileprivate static func remove<Container: AccountValueStorageContainer>(from builder: AccountValueStorageBuilder<Container>) {
        builder.remove(Self.self)
    }

    fileprivate static func setEmpty<Container: AccountValueStorageContainer>(in builder: AccountValueStorageBuilder<Container>) {
        builder.set0(Self.self, value: emptyValue)
    }
}
