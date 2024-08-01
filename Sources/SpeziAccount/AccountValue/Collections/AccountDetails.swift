//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


private struct RemoveVisitor: AccountKeyVisitor {
    private var details: AccountDetails

    init(_ details: AccountDetails) {
        self.details = details
    }

    mutating func visit<Key: AccountKey>(_ key: Key.Type) {
        details.remove(key)
    }

    func final() -> AccountStorage {
        details.storage
    }
}


private struct CopyVisitor: AccountValueVisitor {
    private var details: AccountDetails
    private let allowOverwrite: Bool

    init(_ details: AccountDetails, allowOverwrite: Bool) {
        self.details = details
        self.allowOverwrite = allowOverwrite
    }

    mutating func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
        guard allowOverwrite || !details.contains(Key.self) else {
            return
        }

        details.storage.set(key, value: value)
    }

    func final() -> AccountStorage {
        details.storage
    }
}


private struct CopyKeyVisitor: AccountKeyVisitor {
    let source: AccountDetails
    var destination: AccountDetails
    private let allowOverwrite: Bool

    init(source: AccountDetails, destination: AccountDetails, allowOverwrite: Bool) {
        self.destination = destination
        self.source = source
        self.allowOverwrite = allowOverwrite
    }

    mutating func visit<Key: AccountKey>(_ key: Key.Type) {
        guard let value = source.storage.get(key) else {
            return
        }

        guard allowOverwrite || !destination.contains(Key.self) else {
            return
        }

        destination.storage.set(key, value: value)
    }

    func final() -> AccountStorage {
        destination.storage
    }
}


/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountKey`` for a list of bundled keys.
public struct AccountDetails {
    fileprivate var storage: AccountStorage


    /// Initialize empty account details.
    public init() {
        self.init(from: AccountStorage())
    }


    init(from storage: AccountStorage) {
        self.storage = storage
    }

    /// Retrieve the value for an account key.
    /// - Parameter key: The meta-type of the ``AccountKey``.
    /// - Returns: The value if its currently stored in the collection.
    public subscript<Key: KnowledgeSource<AccountAnchor>>(_ key: Key.Type) -> Key.Value? {
        get {
            storage[Key.self]
        }
        set {
            storage[Key.self] = newValue
        }
    }


    /// Retrieve the value for an account key.
    /// - Parameter key: The meta-type of the ``RequiredAccountKey``.
    /// - Returns: The value if its currently stored in the collection or the default value. Note that retrieving the default value for a ``RequiredAccountKey`` results in a runtime crash.
    @_disfavoredOverload
    public subscript<Key: DefaultProvidingKnowledgeSource<AccountAnchor>>(_ key: Key.Type) -> Key.Value {
        get {
            storage[Key.self]
        }
        set {
            storage[Key.self] = newValue
        }
    }

    /// Retrieve the value for an computed account key.
    /// - Parameter key: The meta-type of the ``AccountKey`` that conforms to `ComputedKnowledgeSource`.
    /// - Returns: The value if its currently stored in the collection or otherwise the computed value.
    public subscript<Key: ComputedKnowledgeSource<AccountAnchor>>(
        _ key: Key.Type
    ) -> Key.Value where Key.StoragePolicy == _StoreComputePolicy {
        mutating get {
            storage[key]
        }
    }

    /// Retrieve the value for an computed account key.
    /// - Parameter key: The meta-type of the ``AccountKey`` that conforms to `ComputedKnowledgeSource`.
    /// - Returns: The computed value of the account key.
    public subscript<Key: ComputedKnowledgeSource<AccountAnchor>>(
        _ key: Key.Type
    ) -> Key.Value where Key.StoragePolicy == _AlwaysComputePolicy {
        key.compute(from: storage)
    }

    /// Retrieve the value for an computed account key.
    /// - Parameter key: The meta-type of the ``AccountKey`` that conforms to `OptionalComputedKnowledgeSource`.
    /// - Returns: The value if its currently stored in the collection or otherwise the computed value.
    public subscript<Key: OptionalComputedKnowledgeSource<AccountAnchor>>(
        _ key: Key.Type
    ) -> Key.Value? where Key.StoragePolicy == _StoreComputePolicy {
        mutating get {
            storage[key]
        }
    }

    /// Retrieve the value for an computed account key.
    /// - Parameter key: The meta-type of the ``AccountKey`` that conforms to `OptionalComputedKnowledgeSource`.
    /// - Returns: The computed value of the account key.
    public subscript<Key: OptionalComputedKnowledgeSource<AccountAnchor>>(
        _ key: Key.Type
    ) -> Key.Value? where Key.StoragePolicy == _AlwaysComputePolicy {
        key.compute(from: storage)
    }
}


extension AccountDetails: Sendable {}


extension AccountDetails: AcceptingAccountValueVisitor {}

// MARK: - Signup

extension AccountDetails {
    /// Checking account details against the user-defined requirements of the `AccountValueConfiguration`.
    ///
    /// Refer to the ``AccountValueConfiguration`` for more information.
    /// - Parameter configuration: The configured provided by the user (see ``Account/configuration``).
    /// - Throws: Throws potential ``AccountOperationError`` if requirements are not fulfilled.
    public func validateAgainstSignupRequirements(_ configuration: AccountValueConfiguration) throws {
        let missing = configuration.filter { configuration in
            configuration.requirement == .required && !self.contains(configuration.key)
        }

        if !missing.isEmpty {
            let keyNames = missing.map { $0.keyPathDescription }

            LoggerKey.defaultValue.warning("\(keyNames) was/were required to be provided but wasn't/weren't provided!")
            throw AccountOperationError.missingAccountValue(keyNames)
        }
    }
}

// MARK: - Collection

extension AccountDetails: Collection {
    public typealias Index = ValueRepository<AccountAnchor>.Index

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
    public subscript(position: Index) -> ValueRepository<AccountAnchor>.Element {
        storage[position]
    }
}


extension AccountDetails {
    /// Retrieve all keys stored in this collection.
    public var keys: [any AccountKey.Type] {
        self.compactMap { element in
            element.anySource as? any AccountKey.Type
        }
    }

    /// Checks if the provided `AccountKey` is stored in the collection.
    /// - Parameter key: The account key to check existence for.
    /// - Returns: Returns `true` if the a value is stored for the given `AccountKey`.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(key)
    }

    /// Check if the provided type-erased `AccountKey` is stored in the collection.
    /// - Parameter key: The account key to check existence for.
    /// - Returns: Returns `true` if the a value is stored for the given `AccountKey`.
    @_disfavoredOverload
    public func contains(_ key: any AccountKey.Type) -> Bool {
        key.anyContains(in: self)
    }

    /// Add the contents from another account details collection.
    /// - Parameters:
    ///   - values: The account details to add.
    ///   - merge: If `true` values contained in `values` will overwrite values already stored in `self`.
    public mutating func add(contentsOf values: AccountDetails, merge: Bool = false) {
        var visitor = CopyVisitor(self, allowOverwrite: merge)
        storage = values.acceptAll(&visitor)
    }

    /// Add the contents from another account details collection but filter for specific keys only.
    /// - Parameters:
    ///   - values: The account details to copy from.
    ///   - keys: The collection of keys to filter the values from`values`.
    ///   - merge: If `true` values contained in `values` will overwrite values already stored in `self`.
    @_disfavoredOverload
    public mutating func add<Keys: AcceptingAccountKeyVisitor>(contentsOf values: AccountDetails, filterFor keys: Keys, merge: Bool = false) {
        var visitor = CopyKeyVisitor(source: values, destination: self, allowOverwrite: merge)
        storage = keys.acceptAll(&visitor)
    }


    /// Add the contents from another account details collection but filter for specific keys only.
    /// - Parameters:
    ///   - values: The account details to copy from.
    ///   - keys: The collection of keys to filter the values from`values`.
    ///   - merge: If `true` values contained in `values` will overwrite values already stored in `self`.
    public mutating func add(contentsOf values: AccountDetails, filterFor keys: [any AccountKey.Type], merge: Bool = false) {
        var visitor = CopyKeyVisitor(source: values, destination: self, allowOverwrite: merge)
        storage = keys.acceptAll(&visitor)
    }

    /// Set the value of an account key.
    /// - Parameters:
    ///   - key: The ``AccountKey`` to set the value for.
    ///   - value: The value that should be set.
    public mutating func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value) {
        storage.set(key, value: value)
    }

    /// Remove a value for a account key.
    /// - Parameter key: The key for which the value should be removed.
    public mutating func remove<Key: AccountKey>(_ key: Key.Type) {
        storage[key] = nil
    }

    /// Remove a value for a account key.
    /// - Parameter key: The key for which the value should be removed.
    @_disfavoredOverload
    public mutating func remove(_ key: any AccountKey.Type) {
        key.anyRemove(in: &self)
    }

    /// Remove the values for a collection of account keys.
    /// - Parameter keys: The list of keys which values are removed from the account details.
    public mutating func removeAll(_ keys: [any AccountKey.Type]) {
        var visitor = RemoveVisitor(self)
        storage = keys.acceptAll(&visitor)
    }

    /// Remove the values for a collection of account keys.
    /// - Parameter keys: The list of keys which values are removed from the account details.
    ///     You can use types like the ``AccountKeyCollection`` or a simple `[any AccountKey.Type]` array.
    @_disfavoredOverload
    public mutating func removeAll<Keys: AcceptingAccountKeyVisitor>(_ keys: Keys) {
        var visitor = RemoveVisitor(self)
        storage = keys.acceptAll(&visitor)
    }
}


extension AccountKey {
    fileprivate static func anyContains(in details: AccountDetails) -> Bool {
        details.contains(Self.self)
    }

    fileprivate static func anyRemove(in details: inout AccountDetails) {
        details.remove(Self.self)
    }
}
