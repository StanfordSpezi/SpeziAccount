//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

// TODO protocols in a separate file!
public protocol AccountValueStorageBaseContainer {
    /// The underlying storage.
    var storage: AccountValueStorage { get }

    /// The count of elements.
    var count: Int { get }

    /// Indicates if the container is empty.
    var isEmpty: Bool { get }

    /// Checks if the provided ``AccountValueKey`` is currently stored in the container.
    func contains<Key: AccountValueKey>(_ key: Key.Type) -> Bool

    func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final
    // TODO todo also support anonymous iteration via collection interface!
}


/// A ``AccountValueStorage`` container.
public protocol AccountValueStorageContainer: AccountValueStorageBaseContainer { // TODO rename to AccountValues?
    /// Builder pattern to build a container of this type.
    typealias Builder = AccountValueStorageBuilder<Self>

    init(from storage: AccountValueStorage) // TODO protocol requirement?

    func merge<Container: AccountValueStorageContainer>(with container: Container) -> Self
}


/// A `ValueRepository` that stores `KnowledgeSource`s anchored to the ``AccountAnchor``.
///
/// This is the underlying storage type user in, e.g., ``AccountDetails``, ``SignupDetails`` or ``ModifiedAccountDetails``.
public typealias AccountValueStorage = ValueRepository<AccountAnchor>


extension AccountValueStorageBaseContainer {
    /// Default implementation delegating to the underlying storage type.
    public var count: Int {
        storage.count
    }

    /// Default implementation delegating to the underlying storage type.
    public var isEmpty: Bool {
        storage.isEmpty
    }

    /// Default contains implementation forwarding to the Shared Repository.
    public func contains<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        storage.contains(key)
    }
}

extension AccountValueStorageContainer {
    public func merge<Container: AccountValueStorageContainer>(with container: Container) -> Self {
        let build = AccountValueStorageBuilder<Self>(from: storage)
        build.merging(container)
        return build.build()
    }
}
