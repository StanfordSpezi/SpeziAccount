//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public protocol AcceptingAccountValueVisitor {
    func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final
}


/// A account value visitor.
///
/// TODO more docs, and example how to use acceptAll?
public protocol AccountValueVisitor {
    associatedtype Final = Void

    func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value)

    func visit<Key: RequiredAccountKey>(_ key: Key.Type, _ value: Key.Value)

    /// The final result of the visitor.
    ///
    /// This method can be used to deliver a final result of the visitor. This method has a
    /// `Void` default implementation.
    ///
    /// - Note: This method is only called if the visitor is used using ``AccountValuesCollection/acceptAll(_:)-4csns``. TODO verify right reference!
    ///     If you directly call ``AccountKey/accept(_:_:)`` this will not be called and has no effect.
    /// - Returns:
    func final() -> Final
}


extension AccountValueVisitor {
    public func visit<Key: RequiredAccountKey>(_ key: Key.Type, _ value: Key.Value) {
        key.defaultAccept(self, value)
    }
}


extension AccountValueVisitor where Final == Void {
    /// Default `Void` implementation.
    public func final() {}
}


extension AccountKey {
    fileprivate static func defaultAccept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Value) {
        visitor.visit(Self.self, value)
    }

    // use by acceptAll
    fileprivate static func anyAccept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Any) {
        guard let value = value as? Value else {
            preconditionFailure("Tried to visit \(Self.self) with value \(value) which is not of type \(Value.self)")
        }

        accept(visitor, value)
    }
}


extension AccountValuesCollection {
    public func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final {
        for entry in self {
            // not all knowledge sources are `AccountKey`
            guard let accountKey = entry.anySource as? any AccountKey.Type else {
                continue
            }

            accountKey.anyAccept(visitor, entry.anyValue)
        }

        return visitor.final()
    }
}
