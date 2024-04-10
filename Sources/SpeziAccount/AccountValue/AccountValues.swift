//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// An arbitrary collection of account values.
public protocol AccountValuesCollection: AcceptingAccountValueVisitor, Collection
    where Index == AccountStorage.Index, Element == AccountStorage.Element {
    /// Checks if the provided ``AccountKey`` is currently stored in the collection.
    func contains<Key: AccountKey>(_ key: Key.Type) -> Bool

    /// Checks if the provided type-erase ``AccountKey`` is currently stored in the collection.
    func contains(anyKey key: any AccountKey.Type) -> Bool
}


/// Storage unit for values of ``AccountKey``s.
///
/// ## Topics
///
/// ### Shared Repository
///
/// - ``AccountAnchor``
/// - ``AccountStorage``
public protocol AccountValues: AccountValuesCollection {
    /// The underlying storage repository.
    var storage: AccountStorage { get }

    /// Retrieve the array of stored key of the repository.
    ///
    /// - Note: This doesn't contain stored `KnowledgeSources` that don't conform to ``AccountKey``.
    var keys: [any AccountKey.Type] { get }

    /// Init from storage repository. Don't use this directly, use a instance of ``Builder``.
    /// - Parameter storage: The storage repository.
    init(from storage: AccountStorage)

    /// Merge with contents from a different ``AccountValues`` instance creating a new unit.
    /// - Parameters:
    ///   - values: The account values to merge with.
    ///   - allowOverwrite: Flag indicating the the provided values might overwrite these already contained in here.
    /// - Returns: The resulting values containing the combination of both ``AccountValues`` instances.
    func merge<Values: AccountValues>(with values: Values, allowOverwrite: Bool) -> Self
}


extension AccountValues {
    /// Builder pattern to build a container of this type.
    public typealias Builder = AccountValuesBuilder<Self>
}


extension AccountValues {
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


extension AccountValues {
    /// Retrieve all keys stored in this collection.
    public var keys: [any AccountKey.Type] {
        self.compactMap { element in
            element.anySource as? any AccountKey.Type
        }
    }

    /// Default contains implementation forwarding to the Shared Repository.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        storage.contains(key)
    }

    /// Default merge implementation.
    public func merge<Values: AccountValues>(with values: Values, allowOverwrite: Bool = false) -> Self {
        let build = AccountValuesBuilder<Self>(from: storage)
        build.merging(values, allowOverwrite: allowOverwrite)
        return build.build()
    }
}

extension AccountValuesCollection {
    /// Default type-erased implementation.
    public func contains(anyKey key: any AccountKey.Type) -> Bool {
        key.anyContains(in: self)
    }
}


extension AccountKey {
    fileprivate static func anyContains<Collection: AccountValuesCollection>(in collection: Collection) -> Bool {
        collection.contains(Self.self)
    }
}
