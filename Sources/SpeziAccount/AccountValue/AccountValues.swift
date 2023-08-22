//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// An arbitrary collection of account values.
public protocol AccountValuesCollection: AcceptingAccountValueVisitor, Collection
    where Index == AccountStorage.Index, Element == AccountStorage.Element {
    /// Checks if the provided ``AccountKey`` is currently stored in the collection.
    func contains<Key: AccountKey>(_ key: Key.Type) -> Bool

    /// Checks if the provided type-erase ``AccountKey`` is currently stored in the collection.
    func contains(_ key: any AccountKey.Type) -> Bool
}


/// Storage unit for values of ``AccountKey``s.
public protocol AccountValues: AccountValuesCollection {
    /// Builder pattern to build a container of this type.
    typealias Builder = AccountValuesBuilder<Self>

    /// The underlying storage repository.
    var storage: AccountStorage { get }

    /// Init from storage repository. Don't use this directly, use a instance of ``Builder``.
    /// - Parameter storage: The storage repository.
    init(from storage: AccountStorage)

    /// Merge with contents from a different ``AccountValues`` instance creating a new unit.
    /// - Parameter values: The account values to merge with.
    /// - Returns: The resulting values containing the combination of both ``AccountValues`` instances.
    func merge<Values: AccountValues>(with values: Values) -> Self
}


extension AccountValues {
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


extension AccountValues {
    /// Default contains implementation forwarding to the Shared Repository.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(key)
    }

    /// Default merge implementation.
    public func merge<Values: AccountValues>(with values: Values) -> Self {
        let build = AccountValuesBuilder<Self>(from: storage)
        build.merging(values)
        return build.build()
    }
}

extension AccountValuesCollection {
    /// Default type-erased implementation.
    public func contains(_ key: any AccountKey.Type) -> Bool {
        key.anyContains(in: self)
    }
}


extension AccountKey {
    fileprivate static func anyContains<Collection: AccountValuesCollection>(in collection: Collection) -> Bool {
        collection.contains(Self.self)
    }
}
