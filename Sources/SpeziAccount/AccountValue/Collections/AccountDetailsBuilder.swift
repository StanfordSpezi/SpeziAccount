//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


/// A class-based builder interface for `AccountDetails` that can be passed around the view hierarchy.
///
/// This type allows to easily build and modify an instance of ``AccountDetails``.
@Observable
class AccountDetailsBuilder {
    var storage: AccountDetails
    var defaultValues: AccountDetails

    /// Initialize a new empty builder.
    convenience init() {
        self.init(from: AccountDetails())
    }

    /// Initialize a new builder by copying the contents of a ``AccountValues`` instance.
    /// - Parameter storage: The storage to copy all values from.
    init(from storage: AccountDetails) {
        self.storage = AccountDetails()
        self.defaultValues = AccountDetails()
    }


    /// Clear the builder's contents.
    func clear() {
        storage = .init()
    }

    /// Retrieve the current value stored in the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The value is present.
    func get<Key: AccountKey>(_ key: Key.Type) -> Key.Value? {
        storage[Key.self]
    }

    /// Store a new value in the builder.
    /// - Parameters:
    ///   - key: The ``AccountKey`` metatype.
    ///   - value: The value to store.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value) -> Self {
        storage.set(key, value: value)
        return self
    }

    @discardableResult
    func set<Key: AccountKey>(_ key: Key.Type, defaultValue value: Key.Value) -> Self {
        defaultValues.set(key, value: value)
        return self
    }

    /// Merge all values from a ``AccountValues`` instance into this builder.
    /// - Parameters:
    ///   - values: The values.
    ///   - merge: Flag controls if the supplied values might overwrite values in the builder
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    func add(contentsOf values: AccountDetails, merge: Bool = false) -> Self {
        storage.add(contentsOf: values, merge: merge)
        return self
    }

    /// Remove a value from the builder.
    /// - Parameter key: The ``AccountKey`` metatype.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    func remove<Key: AccountKey>(_ key: Key.Type) -> Self {
        storage.remove(key)
        return self
    }

    /// Remove a value from the builder using a type-erased ``AccountKey`` metatype.
    /// - Parameter accountKey: The type-erased ``AccountKey``.
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    @_disfavoredOverload
    func remove(_ key: any AccountKey.Type) -> Self {
        storage.remove(key)
        return self
    }

    /// Remove a set of values from the builder given an array of ``AccountKey`` metatypes.
    /// - Parameter keys: The collection of metatypes (e.g., an array or ``AccountKeyCollection``).
    /// - Returns: The builder reference for method chaining.
    @discardableResult
    func removeAll<Keys: AcceptingAccountKeyVisitor>(_ keys: Keys) -> Self {
        storage.removeAll(keys)
        return self
    }

    /// Remove a set of values from the builder given an array of ``AccountKey`` metatypes.
    /// - Parameter keys: The collection of metatypes (e.g., an array or ``AccountKeyCollection``).
    /// - Returns: The builder reference for method chaining.
    func removeAll(_ keys: [any AccountKey.Type]) -> Self {
        storage.removeAll(keys)
        return self
    }

    /// Checks if a value for a ``AccountKey`` is present in the builder.
    /// - Parameter key: The ``AccountKey`` metatype to check if a value exists.
    /// - Returns: Returns `true` if present, otherwise `false`.
    func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(Key.self)
    }

    /// Checks if a value for a ``AccountKey`` is present in the builder.
    /// - Parameter key: The ``AccountKey`` metatype to check if a value exists.
    /// - Returns: Returns `true` if present, otherwise `false`.
    func contains(_ key: any AccountKey.Type) -> Bool {
        storage.contains(key)
    }

    /// Build a new storage instance.
    /// - Returns: The built ``AccountValues``.
    func build() -> AccountDetails {
        if !defaultValues.isEmpty {
            storage.add(contentsOf: defaultValues, merge: false)
            return storage
        } else {
            return storage
        }
    }
}


extension AccountDetailsBuilder: Collection {
    typealias Index = AccountStorage.Index

    var startIndex: Index {
        storage.startIndex
    }

    var endIndex: Index {
        storage.endIndex
    }


    func index(after index: Index) -> Index {
        storage.index(after: index)
    }


    subscript(position: Index) -> AnyRepositoryValue {
        storage[position]
    }
}

extension AccountDetailsBuilder {
    @discardableResult
    func setEmptyValue(for accountKey: any AccountKey.Type) -> Self {
        accountKey.setEmpty(in: self)
        return self
    }
}


extension AccountKey {
    fileprivate static func setEmpty(in builder: AccountDetailsBuilder) {
        builder.set(Self.self, value: initialValue.value)
    }
}
