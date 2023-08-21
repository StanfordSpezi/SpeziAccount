//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


// TODO protocols in a separate file!
public protocol AccountValuesCollection: AcceptingAccountValueVisitor, Collection
    where Index == AccountStorage.Index, Element == AccountStorage.Element {
    /// Checks if the provided ``AccountKey`` is currently stored in the collection.
    func contains<Key: AccountKey>(_ key: Key.Type) -> Bool

    /// Checks if the provided type-erase ``AccountKey`` is currently stored in the collection.
    func contains(_ key: any AccountKey.Type) -> Bool
}


/// Storage unit for values of ``AccountKey``s.
public protocol AccountValues: AccountValuesCollection { // TODO rename to AccountValues?
    /// Builder pattern to build a container of this type.
    typealias Builder = AccountValuesBuilder<Self>

    /// The underlying storage.
    var storage: AccountStorage { get }

    init(from storage: AccountStorage) // TODO protocol requirement?

    func merge<Container: AccountValues>(with container: Container) -> Self
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

    public func merge<Container: AccountValues>(with container: Container) -> Self {
        let build = AccountValuesBuilder<Self>(from: storage)
        build.merging(container)
        return build.build()
    }
}

extension AccountValuesCollection {
    public func contains(_ key: any AccountKey.Type) -> Bool {
        key.anyContains(in: self)
    }
}


extension AccountKey {
    fileprivate static func anyContains<Collection: AccountValuesCollection>(in collection: Collection) -> Bool {
        collection.contains(Self.self)
    }
}
