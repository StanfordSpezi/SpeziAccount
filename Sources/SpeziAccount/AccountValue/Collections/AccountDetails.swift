//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountKey`` for a list of bundled keys.
public struct AccountDetails {
    private(set) var storage: AccountStorage


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
    public func contains(_ key: any AccountKey.Type) -> Bool {
        key.anyContains(in: self)
    }

    /// Add the contents from another account details collection.
    /// - Parameters:
    ///   - values: The account details to add.
    ///   - merge: If `true` values contained in `values` will overwrite values already stored in `self`.
    /// - Returns: The resulting values containing the combination of both collections.
    public func add(contentsOf values: AccountDetails, merge: Bool = false) -> Self {
        let build = AccountValuesBuilder(from: storage)
        build.merging(values, allowOverwrite: merge) // TODO: rename as well!
        return build.build()
    }
}


extension AccountKey {
    fileprivate static func anyContains(in details: AccountDetails) -> Bool {
        details.contains(Self.self)
    }
}
