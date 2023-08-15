//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A ``AccountValueStorage`` container.
public protocol AccountValueStorageContainer {
    /// Builder pattern to build a container of this type.
    typealias Builder = AccountValueStorageBuilder<Self>

    /// The underlying storage.
    var storage: AccountValueStorage { get }

    /// Checks if the provided ``AccountValueKey`` is currently stored in the container.
    func contains<Key: AccountValueKey>(_ key: Key.Type) -> Bool
}

/// A `ValueRepository` that stores `KnowledgeSource`s anchored to the ``AccountAnchor``.
///
/// This is the underlying storage type user in, e.g., ``AccountDetails``, ``SignupDetails`` or ``ModifiedAccountDetails``.
public typealias AccountValueStorage = ValueRepository<AccountAnchor>


extension AccountValueStorageContainer {
    /// Default contains implementation forwarding to the Shared Repository.
    public func contains<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        storage.contains(key)
    }
}
