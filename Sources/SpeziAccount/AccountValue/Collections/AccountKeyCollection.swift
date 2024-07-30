//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// An `AccountKey` refined with a KeyPath-based description.
///
/// This protocol combines an ``AccountKey`` reference with user-printable information of the KeyPath to ``AccountDetails``.
/// A custom description is derived from the KeyPath name. E.g., we derive a description
/// like `"\.userId"` (as it's extension defined on ``AccountDetails``) for a more user friendly description.
public protocol AccountKeyWithDescription: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The associated `Key` type.
    associatedtype Key: AccountKey

    /// Access to the ``AccountKey`` metatype.
    var key: Key.Type { get }
}


struct AccountKeyWithKeyPathDescription<Key: AccountKey>: AccountKeyWithDescription {
    let key: Key.Type
    let description: String

    var debugDescription: String {
        description
    }

    init(_ keyPath: KeyPath<AccountKeys, Key.Type>) {
        self.key = Key.self
        self.description = keyPath.shortDescription
    }
}


/// A collection of ``AccountKey``s that is built using `KeyPath`-based specification.
///
/// Using the `KeyPath`-based result builder ``AccountKeyCollectionBuilder`` we can preserve user-friendly
/// naming in debug messages (see ``AccountKeyWithDescription``).
///
/// ## Topics
///
/// ### Result Builder
///
/// - ``AccountKeyCollectionBuilder``
/// - ``AccountKeyWithDescription``
public struct AccountKeyCollection: Sendable, AcceptingAccountKeyVisitor {
    private let elements: [any AccountKeyWithDescription]


    /// Initialize a empty collection.
    public init() {
        self.elements = []
    }

    /// Initialize a new collection with elements.
    /// - Parameter keys: The result builder to build the collection.
    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountKeyWithDescription]) {
        self.elements = keys()
    }


    public func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: inout Visitor) -> Visitor.Final {
        self
            .map { $0.key }
            .acceptAll(&visitor)
    }

    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        elements.contains(where: { $0.key == key })
    }
}


extension AccountKeyCollection: Collection {
    public var startIndex: Int {
        elements.startIndex
    }

    public var endIndex: Int {
        elements.endIndex
    }

    public func index(after index: Int) -> Int {
        elements.index(after: index)
    }


    public subscript(position: Int) -> any AccountKeyWithDescription {
        elements[position]
    }
}
