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
