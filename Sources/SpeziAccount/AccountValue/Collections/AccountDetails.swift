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

    func final() -> AccountDetails {
        details
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
        if allowOverwrite || !details.contains(Key.self) {
            details.storage.set(key, value: value)
        }
    }

    func final() -> AccountDetails {
        details
    }
}


/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountKey`` for a list of bundled keys.
public struct AccountDetails {
    var storage: AccountStorage // TODO: fileprivate?


    /// Initialize empty account details.
    public init() {
        self.init(from: AccountStorage())
    }


    init(from storage: AccountStorage) {
        self.storage = storage
    }

    mutating func patchAccountServiceConfiguration(_ configuration: AccountServiceConfiguration) {
        storage[AccountServiceConfigurationDetailsKey.self] = configuration
    }

    mutating func patchIsNewUser(_ isNewUser: Bool) {
        storage[IsNewUserKey.self] = isNewUser
    }
}


extension AccountDetails: Sendable {}


extension AccountDetails: AcceptingAccountValueVisitor {
}


extension AccountDetails: Collection {
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
    public subscript(position: Index) -> AccountStorage.Element {
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
    /// - Returns: The resulting values containing the combination of both collections.
    public mutating func add(contentsOf values: AccountDetails, merge: Bool = false) {
        var visitor = CopyVisitor(self, allowOverwrite: merge)
        storage = values.acceptAll(&visitor).storage
    }

    public mutating func remove<Key: AccountKey>(_ key: Key.Type) { // TODO: remove any key?
        storage[key] = nil // TODO: KeyPath based one? (or just dynamicMemberLookup nil?
    }

    // TODO: public func remove<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> Self {

    @_disfavoredOverload
    public mutating func remove(_ key: any AccountKey.Type) {
        key.anyRemove(in: &self)
    }

    @_disfavoredOverload
    public mutating func removeAll<Keys: AcceptingAccountKeyVisitor>(_ keys: Keys) {
        var visitor = RemoveVisitor(self)
        storage = keys.acceptAll(&visitor).storage
    }

    public mutating func removeAll(_ keys: [any AccountKey.Type]) {
        var visitor = RemoveVisitor(self)
        storage = keys.acceptAll(&visitor).storage
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
