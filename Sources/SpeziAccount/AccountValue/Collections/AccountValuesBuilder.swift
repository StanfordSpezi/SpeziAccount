//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


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
public class AccountValuesBuilder { // TODO: rename AccountDetailsBuilder
    var storage: AccountDetails
    var defaultValues: AccountDetails

    /// Initialize a new empty builder.
    public convenience init() {
        self.init(from: AccountDetails())
    }

    /// Initialize a new builder by copying the contents of a ``AccountValues`` instance.
    /// - Parameter storage: The storage to copy all values from.
    public init(from storage: AccountDetails) {
        self.storage = AccountDetails()
        self.defaultValues = AccountDetails()
    }


    /// Clear the builder's contents.
    public func clear() {
        storage = .init()
    }

    /// Retrieve the current value stored in the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The value is present.
    public func get<Key: AccountKey>(_ key: Key.Type) -> Key.Value? {
        storage.storage.get(key) // TODO: naming
    }

    /// Store a new value in the builder.
    /// - Parameters:
    ///   - key: The ``AccountKey`` metatype.
    ///   - value: The value to store.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value?) -> Self {
        storage.storage[Key.self] = value // TODO: naming
        return self
    }

    @discardableResult
    func set<Key: AccountKey>(_ key: Key.Type, defaultValue: Key.Value) -> Self {
        defaultValues.storage[Key.self] = defaultValue
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
    ///   - merge: Flag controls if the supplied values might overwrite values in the builder
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func add(contentsOf values: AccountDetails, merge: Bool = false) -> Self {
        storage.add(contentsOf: values, merge: merge)
        return self
    }

    /// Merge all values specified by a collections of ``AccountKey``s which values are stored in some ``AccountValues`` instance.
    /// - Parameters:
    ///   - keys: The keys for which to copy account values.
    ///   - values: The container from where to retrieve the values.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func merging<Keys: AcceptingAccountKeyVisitor>(
        keys: Keys,
        from values: AccountDetails,
        merge: Bool = false
    ) -> Self {
        storage.add(contentsOf: values, filterFor: keys, merge: merge)
        return self
    }

    /// Remove a value from the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func remove<Key: AccountKey>(_ key: Key.Type) -> Self {
        storage.remove(key)
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
    @_disfavoredOverload
    public func remove(_ key: any AccountKey.Type) -> Self {
        storage.remove(key)
        return self
    }

    /// Remove a set of values from the builder given an array of ``AccountKey`` metatypes.
    /// - Parameter keys: The collection of metatypes (e.g., an array or ``AccountKeyCollection``).
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    public func removeAll<Keys: AcceptingAccountKeyVisitor>(_ keys: Keys) -> Self {
        storage.removeAll(keys)
        return self
    }

    public func removeAll(_ keys: [any AccountKey.Type]) -> Self {
        storage.removeAll(keys)
        return self
    }

    /// Checks if a value for a ``AccountKey`` is present in the builder.
    /// - Parameter key: The ``AccountKey`` metatype to check if a value exists.
    /// - Returns: Returns `true` if present, otherwise `false`.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(Key.self) // TODO: contains visitor?
    }

    public func contains(_ key: any AccountKey.Type) -> Bool {
        storage.contains(key)
    }

    /// Build a new storage instance.
    /// - Returns: The built ``AccountValues``.
    public func build() -> AccountDetails {
        if !defaultValues.isEmpty {
            storage.add(contentsOf: defaultValues, merge: false)
            return storage
        } else {
            return storage
        }
    }
}


extension AccountValuesBuilder: Collection {
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
}

extension AccountValuesBuilder {
    @discardableResult
    func setEmptyValue(for accountKey: any AccountKey.Type) -> Self {
        accountKey.setEmpty(in: self)
        return self
    }
}


extension AccountKey {
    fileprivate static func setEmpty(in builder: AccountValuesBuilder) {
        builder.set(Self.self, value: initialValue.value)
    }
}
