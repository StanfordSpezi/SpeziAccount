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

    init(key: Key.Type, description: String) {
        self.key = key
        self.description = description
    }

    init(_ keyPath: KeyPath<AccountKeys, Key.Type>) {
        self.key = Key.self
        self.description = keyPath.shortDescription
    }
}


/// A collection of `AccountKey`s that is built using `KeyPath`-based specification.
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
public struct AccountKeyCollection {
    private var elements: [any AccountKeyWithDescription]

    /// The type-erased array of keys stored in the collection.
    public var _keys: [any AccountKey.Type] { // swiftlint:disable:this identifier_name
        elements.map { $0.key }
    }

    /// Initialize a empty collection.
    public init() {
        self.elements = []
    }

    init(_ elements: [any AccountKeyWithDescription]) {
        self.elements = elements
    }

    /// Initialize a new collection with elements.
    /// - Parameter keys: The result builder to build the collection.
    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountKeyWithDescription]) {
        self.elements = keys()
    }

    /// Checks if the provided `AccountKey` is stored in the collection.
    /// - Parameter key: The account key to check existence for.
    /// - Returns: Returns `true` if the a value is stored for the given `AccountKey`.
    public func contains<Key: AccountKey>(_ key: Key.Type) -> Bool {
        elements.contains(where: { $0.key == key })
    }

    /// Remove the keys from the collection.
    /// - Parameter keys: The list of keys which are removed from the collection.
    public mutating func removeAll(_ keys: [any AccountKey.Type]) {
        let contained = Set(keys.map { ObjectIdentifier($0) })
        elements.removeAll { key in
            contained.contains(ObjectIdentifier(key.key))
        }
    }


    /// Remove the keys from the collection.
    /// - Parameter keys: The list of keys which are removed from the collection.
    ///     You can use types like the ``AccountKeyCollection`` or a simple `[any AccountKey.Type]` array.
    @_disfavoredOverload
    public mutating func removeAll<Keys: AcceptingAccountKeyVisitor>(_ keys: Keys) {
        removeAll(keys._keys)
    }
}


extension AccountKeyCollection: Sendable, AcceptingAccountKeyVisitor {
    public func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: inout Visitor) -> Visitor.Final {
        self
            .map { $0.key }
            .acceptAll(&visitor)
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
