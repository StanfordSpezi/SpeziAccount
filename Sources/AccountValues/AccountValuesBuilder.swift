//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


private class RemoveVisitor<Values: AccountValues>: AccountKeyVisitor {
    let builder: AccountValuesBuilder<Values>

    init(builder: AccountValuesBuilder<Values>) {
        self.builder = builder
    }

    func visit<Key: AccountKey>(_ key: Key.Type) {
        builder.remove(key)
    }
}


private class CopyVisitor<Values: AccountValues>: AccountValueVisitor {
    let builder: AccountValuesBuilder<Values>
    let allowOverwrite: Bool

    init(builder: AccountValuesBuilder<Values>, allowOverwrite: Bool) {
        self.builder = builder
        self.allowOverwrite = allowOverwrite
    }

    func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
        if allowOverwrite || !builder.contains(Key.self) {
            builder.set(key, value: value)
        }
    }
}


private class CopyKeyVisitor<Destination: AccountValues, Source: AccountValues>: AccountKeyVisitor {
    let destination: AccountValuesBuilder<Destination>
    let source: Source

    init(destination: AccountValuesBuilder<Destination>, source: Source) {
        self.destination = destination
        self.source = source
    }

    func visit<Key: AccountKey>(_ key: Key.Type) {
        if let value = source.storage.get(key) {
            destination.set(key, value: value)
        }
    }
}


/// A builder interface for any ``AccountValues`` conforming types.
///
/// This type allows to easily build and modify an instance of ``AccountValues``.
/// Use the ``AccountValues/Builder`` typealias to instantiate a builder for any given ``AccountValues`` implementation.
///
/// ## Topics
///
/// ### Creating a new builder
/// - ``AccountValuesBuilder/init()``
/// - ``AccountValuesBuilder/init(from:)``
///
/// ### Setting a Account Value
/// - ``AccountValuesBuilder/set(_:value:)-6s8dc``
/// - ``AccountValuesBuilder/set(_:value:)-1qcx7``
///
/// ### Merging
/// - ``AccountValuesBuilder/merging(_:allowOverwrite:)``
/// - ``AccountValuesBuilder/merging(with:from:)``
///
/// ### Removal
/// - ``AccountValuesBuilder/remove(_:)-99d1h``
/// - ``AccountValuesBuilder/remove(_:)-5m271``
/// - ``AccountValuesBuilder/remove(any:)``
/// - ``AccountValuesBuilder/remove(all:)``
///
/// ### Building
/// - ``AccountValuesBuilder/build()-pqt5``
/// - ``AccountValuesBuilder/build(owner:)``
/// - ``AccountValuesBuilder/build(checking:)``
@Observable
public class AccountValuesBuilder<Values: AccountValues>: AccountValuesCollection {
    var storage: AccountStorage
    var defaultValues: AccountStorage


    init(from storage: AccountStorage) {
        self.storage = storage
        self.defaultValues = AccountStorage()
    }

    /// Initialize a new empty builder.
    public convenience init() {
        self.init(from: .init())
    }

    /// Initialize a new builder by copying the contents of a ``AccountValues`` instance.
    /// - Parameter storage: The storage to copy all values from.
    public convenience init<Source: AccountValues>(from storage: Source) {
        self.init(from: storage.storage)
    }


    /// Clear the builder's contents.
    public func clear() {
        storage = .init()
    }

    /// Retrieve the current value stored in the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The value is present.
    public func get<Key: AccountKey>(_ key: Key.Type) -> Key.Value? {
        storage.get(key)
    }

    /// Store a new value in the builder.
    /// - Parameters:
    ///   - key: The ``AccountKey`` metatype.
    ///   - value: The value to store.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        if let value {
            storage[Key.self] = value
        }
        return self
    }

    @discardableResult
    func set<Key: AccountKey>(_ key: Key.Type, defaultValue: Key.Value) -> Self {
        defaultValues[Key.self] = defaultValue
        return self
    }

    /// Store a new value in the builder using `KeyPath` notation.
    /// - Parameters:
    ///   - keyPath: The ``AccountKey`` metatype referenced by a `KeyPath`.
    ///   - value: The value to store.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func set<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>, value: Key.Value?) -> Self {
        set(Key.self, value: value)
    }

    /// Merge all values from a ``AccountValues`` instance into this builder.
    /// - Parameters:
    ///   - values: The values.
    ///   - allowOverwrite: Flag controls if the supplied values might overwrite values in the builder
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func merging<OtherValues: AccountValues>(_ values: OtherValues, allowOverwrite: Bool) -> Self {
        values.acceptAll(CopyVisitor(builder: self, allowOverwrite: allowOverwrite))
        return self
    }

    /// Merge all values specified by a collections of ``AccountKey``s which values are stored in some ``AccountValues`` instance.
    /// - Parameters:
    ///   - keys: The keys for which to copy account values.
    ///   - values: The container from where to retrieve the values.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func merging<Keys: AcceptingAccountKeyVisitor, OtherValues: AccountValues>(
        with keys: Keys,
        from values: OtherValues
    ) -> Self {
        keys.acceptAll(CopyKeyVisitor(destination: self, source: values))
        return self
    }

    /// Remove a value from the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func remove<Key: AccountKey>(_ key: Key.Type) -> Self {
        storage[key] = nil
        return self
    }

    /// Remove a value from the builder using `KeyPath` notation.
    /// - Parameter keyPath: The ``AccountKey`` metatype reference by a `KeyPath`.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func remove<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> Self {
        remove(Key.self)
    }

    /// Remove a value from the builder using a type-erased ``AccountKey`` metatype.
    /// - Parameter accountKey: The type-erased ``AccountKey``.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func remove(any accountKey: any AccountKey.Type) -> Self {
        accountKey.accept(RemoveVisitor(builder: self))
        return self
    }

    /// Remove a set of values from the builder given an array of ``AccountKey`` metatypes.
    /// - Parameter keys: The collection of metatypes (e.g., an array or ``AccountKeyCollection``).
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func remove<Keys: AcceptingAccountKeyVisitor>(all keys: Keys) -> Self {
        keys.acceptAll(RemoveVisitor(builder: self))
        return self
    }

    /// Checks if a value for a ``AccountKey`` is present in the builder.
    /// - Parameter key: The ``AccountKey`` metatype to check if a value exists.
    /// - Returns: Returns `true` if present, otherwise `false`.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(Key.self)
    }

    /// Build a new storage instance.
    /// - Returns: The built ``AccountValues``.
    public func build() -> Values {
        if !defaultValues.isEmpty {
            // .merge(with:allowOverwrite:) is implemented using account values builder.
            // without this isEmpty check we would run an infinite recursion.
            // Calling merge on the built container ensures that this build() method doesn't have any side effects.
            return Values(from: storage)
                .merge(with: Values(from: defaultValues), allowOverwrite: false)
        } else {
            return Values(from: storage)
        }
    }
}


extension AccountValuesBuilder {
    /// Default `Collection` implementation.
    public typealias Index = AccountStorage.Index

    /// Default `Collection` implementation.
    public var startIndex: Index {
        storage.startIndex
    }

    /// Default `Collection` implementation.
    public var endIndex: Index {
        storage.endIndex
    }

    /// Default `Collection` implementation.
    public func index(after index: Index) -> Index {
        storage.index(after: index)
    }


    /// Default `Collection` implementation.
    public subscript(position: Index) -> AnyRepositoryValue {
        storage[position]
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
    fileprivate static func setEmpty<Values: AccountValues>(in builder: AccountValuesBuilder<Values>) {
        builder.set(Self.self, value: initialValue.value)
    }
}
