//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A collection type that is capable of accepting an ``AccountKeyVisitor``.
public protocol AcceptingAccountKeyVisitor {
    /// Accepts an ``AccountKeyVisitor`` for all elements of the collection.
    /// - Parameter visitor: The visitor to accept.
    /// - Returns: The ``AccountKeyVisitor/Final`` result or `Void`.
    func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: Visitor) -> Visitor.Final
}


/// A visitor to visit ``AccountKey`` metatypes.
///
/// Use the ``AcceptingAccountKeyVisitor/acceptAll(_:)-5upqf`` method on supporting types to
/// visit all contained metatypes.
public protocol AccountKeyVisitor {
    /// A optional final result type returned by ``final()-66gfx``.
    associatedtype Final = Void

    /// Visit a single ``AccountKey`` metatype.
    /// - Parameter key: The ``AccountKey`` metatype.
    func visit<Key: AccountKey>(_ key: Key.Type)

    /// Visit a single ``RequiredAccountKey`` metatype.
    ///
    /// - Note: If the implementation is not provided, the call is automatically forwarded to ``visit(_:)-3qt1c``.
    /// - Parameter key: The ``RequiredAccountKey`` metatype.
    func visit<Key: RequiredAccountKey>(_ key: Key.Type)

    /// the final result of the visitor.
    ///
    /// This method can be used to deliver a final result of the visitor. This method has a `Void` default implementation.
    ///
    /// - Note: THis method is only called if the visitor is used using ``AcceptingAccountKeyVisitor/acceptAll(_:)-5upqf``.
    ///     If you directly call ``AccountKey/accept(_:)`` this will not be called and has no effect.
    /// - Returns: The final result.
    func final() -> Final
}


extension AccountKeyVisitor {
    /// Default implementation forwarding to ``visit(_:)-3qt1c``.
    public func visit<Key: RequiredAccountKey>(_ key: Key.Type) {
        key.defaultAccept(self)
    }
}


extension AccountKeyVisitor where Final == Void {
    /// Default `Void` implementation.
    public func final() {}
}


extension AccountKey {
    fileprivate static func defaultAccept<Visitor: AccountKeyVisitor>(_ visitor: Visitor) {
        visitor.visit(Self.self)
    }

    // use by acceptAll
    fileprivate static func anyAccept<Visitor: AccountKeyVisitor>(_ visitor: Visitor) {
        accept(visitor)
    }
}


extension AcceptingAccountKeyVisitor where Self: Collection, Element == any AccountKey.Type {
    /// Default acceptAll visitor.
    public func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: Visitor) -> Visitor.Final {
        for key in self {
            key.anyAccept(visitor)
        }

        return visitor.final()
    }
}


extension Array: AcceptingAccountKeyVisitor where Element == any AccountKey.Type {}
