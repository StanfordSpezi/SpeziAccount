//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


private struct RemoveVisitor<Container: AccountValues>: AccountKeyVisitor {
    let builder: AccountValuesBuilder<Container>

    func visit<Key: AccountKey>(_ key: Key.Type) {
        builder.remove(key)
    }
}


private struct CopyVisitor<Container: AccountValues>: AccountValueVisitor {
    let builder: AccountValuesBuilder<Container>

    func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
        builder.set(key, value: value)
    }
}


private struct CopyKeyVisitor<Destination: AccountValues, Source: AccountValues>: AccountKeyVisitor {
    let destination: AccountValuesBuilder<Destination>
    let source: Source

    func visit<Key: AccountKey>(_ key: Key.Type) {
        if let value = source.storage.get(key) {
            destination.set(key, value: value)
        }
    }
}


public class AccountValuesBuilder<Container: AccountValues>: ObservableObject, AccountValuesCollection {
    @Published var storage: AccountStorage


    init(from storage: AccountStorage) {
        self.storage = storage
    }

    public convenience init() {
        self.init(from: .init())
    }

    public convenience init<Source: AccountValues>(from storage: Source) {
        self.init(from: storage.storage)
    }


    public func clear() {
        storage = .init()
    }

    public func get<Key: AccountKey>(_ key: Key.Type) -> Key.Value? {
        storage.get(key)
    }

    @discardableResult public func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        if let value {
            storage[Key.self] = value
        }
        return self
    }

    @discardableResult public func set<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>, value: Key.Value?) -> Self {
        set(Key.self, value: value)
    }

    public func merging<Container: AccountValues>(_ container: Container) {
        container.acceptAll(CopyVisitor(builder: self))
    }

    public func merging<Container: AccountValues, Keys: AcceptingAccountKeyVisitor>(
        with keys: Keys,
        from container: Container
    ) {
        keys.acceptAll(CopyKeyVisitor(destination: self, source: container))
    }

    @discardableResult public func remove<Key: AccountKey>(_ key: Key.Type) -> Self {
        storage[key] = nil
        return self
    }

    @discardableResult public func remove<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> Self {
        remove(Key.self)
    }

    @discardableResult public func remove(any accountValue: any AccountKey.Type) -> Self {
        accountValue.accept(RemoveVisitor(builder: self))
        return self
    }

    public func build() -> Container {
        Container(from: storage)
    }
}


extension AccountValuesBuilder {
    public typealias Index = AccountStorage.Index

    public var startIndex: Index {
        storage.startIndex
    }

    public var endIndex: Index {
        storage.endIndex
    }

    public func index(after index: Index) -> Index {
        storage.index(after: index)
    }


    public subscript(position: Index) -> AnyRepositoryValue {
        storage[position]
    }

    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(Key.self)
    }
}

extension AccountValuesBuilder {
    @discardableResult
    func setEmptyValue(for accountKey: any AccountKey.Type) -> Self {
        accountKey.setEmpty(in: self)
        return self
    }
}


extension AccountKey {
    fileprivate static func setEmpty<Container: AccountValues>(in builder: AccountValuesBuilder<Container>) {
        builder.set(Self.self, value: emptyValue)
    }
}
