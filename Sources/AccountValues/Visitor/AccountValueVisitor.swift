//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A collection type that is capable of accepting an ``AccountValueVisitor``.
public protocol AcceptingAccountValueVisitor {
    /// Accepts an ``AccountValueVisitor`` for all elements of the collection.
    /// - Parameter visitor: The visitor to accept.
    /// - Returns: The ``AccountValueVisitor/Final`` result or `Void`.
    func acceptAll<Visitor: AccountValueVisitor>(_ visitor: inout Visitor) -> Visitor.Final

    /// Accepts an ``AccountValueVisitor`` for all elements of the collection.
    /// - Parameter visitor: The visitor to accept. Provided as a reference type.
    /// - Returns: The ``AccountValueVisitor/Final`` result or `Void`.
    func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final where Visitor: AnyObject
}


/// A visitor to visit ``AccountKey``s and their corresponding values.
///
/// Use the ``AcceptingAccountValueVisitor/acceptAll(_:)-9hgw5`` method on supporting types to visit all contained values.
public protocol AccountValueVisitor {
    /// A optional final result type returned by ``final()-7apm4``.
    associatedtype Final = Void

    /// Visit a single ``AccountKey`` and it's value.
    /// - Parameters:
    ///   - key: The ``AccountKey`` metatype.
    ///   - value: The stored value.
    mutating func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value)

    /// Visit a single ``RequiredAccountKey`` and it's value.
    ///
    /// - Note: If the implementation is not provided, the call is automatically forwarded to ``visit(_:_:)-35w7i``.
    /// - Parameters:
    ///   - key: The ``RequiredAccountKey`` metatype.
    ///   - value: The stored value
    mutating func visit<Key: RequiredAccountKey>(_ key: Key.Type, _ value: Key.Value)

    /// The final result of the visitor.
    ///
    /// This method can be used to deliver a final result of the visitor. This method has a `Void` default implementation.
    ///
    /// - Note: This method is only called if the visitor is used using ``AcceptingAccountValueVisitor/acceptAll(_:)-9hgw5``.
    ///     If you directly call ``AccountKey/accept(_:_:)-8fw0g`` this will not be called and has no effect.
    /// - Returns: The final result.
    mutating func final() -> Final
}


extension AccountValueVisitor {
    /// Default implementation forwarding to ``visit(_:_:)-35w7i``.
    public mutating func visit<Key: RequiredAccountKey>(_ key: Key.Type, _ value: Key.Value) {
        key.defaultAccept(&self, value)
    }
}


extension AccountValueVisitor where Final == Void {
    /// Default `Void` implementation.
    public func final() {}
}


extension AccountKey {
    fileprivate static func defaultAccept<Visitor: AccountValueVisitor>(_ visitor: inout Visitor, _ value: Value) {
        visitor.visit(Self.self, value)
    }

    // use by acceptAll
    fileprivate static func anyAccept<Visitor: AccountValueVisitor>(_ visitor: inout Visitor, _ value: Any) {
        guard let value = value as? Value else {
            preconditionFailure("Tried to visit \(Self.self) with value \(value) which is not of type \(Value.self)")
        }

        accept(&visitor, value)
    }
}


extension AccountValuesCollection {
    /// Default acceptAll visitor.
    public func acceptAll<Visitor: AccountValueVisitor>(_ visitor: inout Visitor) -> Visitor.Final {
        for entry in self {
            // not all knowledge sources are `AccountKey`
            guard let accountKey = entry.anySource as? any AccountKey.Type else {
                continue
            }

            accountKey.anyAccept(&visitor, entry.anyValue)
        }

        return visitor.final()
    }

    /// Default acceptAll visitor for reference types.
    public func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final where Visitor: AnyObject {
        var visitor = visitor
        return acceptAll(&visitor)
    }
}
