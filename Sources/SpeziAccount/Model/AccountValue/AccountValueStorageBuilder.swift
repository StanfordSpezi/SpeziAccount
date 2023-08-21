//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


public class AccountValueStorageBuilder<Container: AccountValueStorageContainer>: ObservableObject, AccountValueStorageBaseContainer {
    @Published public var storage: AccountValueStorage // TODO make some protocol such that this can stay internal!


    init(from storage: AccountValueStorage) {
        self.storage = storage
    }

    public convenience init() {
        self.init(from: .init())
    }

    public convenience init<Source: AccountValueStorageContainer>(from storage: Source) {
        self.init(from: storage.storage)
    }


    public func clear() {
        storage = .init()
    }

    public func get<Key: AccountValueKey>(_ key: Key.Type) -> Key.Value? {
        storage.get(key)
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        if let value {
            storage[Key.self] = value
        }
        return self
    }

    @discardableResult
    public func set<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, value: Key.Value?) -> Self {
        set(Key.self, value: value)
    }

    public func merging<Container: AccountValueStorageContainer>(_ container: Container) {
        container.acceptAll(CopyVisitor(builder: self))
    }

    public func merging<Container: AccountValueStorageContainer, Keys: AcceptingAccountKeyVisitor>(
        with keys: Keys,
        from container: Container
    ) {
        keys.acceptAll(CopyKeyVisitor(destination: self, source: container))
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

    @discardableResult
    public func remove(any accountValue: any AccountValueKey.Type) -> Self {
        accountValue.accept(RemoveVisitor(builder: self))
        return self
    }

    public func build() -> Container {
        Container(from: storage)
    }
}


extension AccountValueStorageBuilder {
    @discardableResult
    func setEmptyValue(for accountValue: any AccountValueKey.Type) -> Self {
        accountValue.setEmpty(in: self)
        return self
    }
}


extension AccountValueKey {
    fileprivate static func setEmpty<Container: AccountValueStorageContainer>(in builder: AccountValueStorageBuilder<Container>) {
        builder.set(Self.self, value: emptyValue)
    }
}

private struct RemoveVisitor<Container: AccountValueStorageContainer>: AccountKeyVisitor {
    let builder: AccountValueStorageBuilder<Container>

    func visit<Key: AccountValueKey>(_ key: Key.Type) {
        builder.remove(key)
    }
}

private struct CopyVisitor<Container: AccountValueStorageContainer>: AccountValueVisitor {
    let builder: AccountValueStorageBuilder<Container>

    func visit<Key: AccountValueKey>(_ key: Key.Type, _ value: Key.Value) {
        builder.set(key, value: value)
    }
}

private struct CopyKeyVisitor<Destination: AccountValueStorageContainer, Source: AccountValueStorageContainer>: AccountKeyVisitor {
    let destination: AccountValueStorageBuilder<Destination>
    let source: Source

    func visit<Key: AccountValueKey>(_ key: Key.Type) {
        if let value = source.storage.get(key) {
            destination.set(key, value: value)
        }
    }
}
