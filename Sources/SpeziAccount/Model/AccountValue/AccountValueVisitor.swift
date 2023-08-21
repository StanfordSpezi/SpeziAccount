//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A account value visitor.
///
/// TODO more docs, and example how to use acceptAll?
public protocol AccountValueVisitor {
    associatedtype Final = Void

    func visit<Key: AccountValueKey>(_ key: Key.Type, _ value: Key.Value)

    func visit<Key: RequiredAccountValueKey>(_ key: Key.Type, _ value: Key.Value)

    /// The final result of the visitor.
    ///
    /// This method can be used to deliver a final result of the visitor. This method has a
    /// `Void` default implementation.
    ///
    /// - Note: This method is only called if the visitor is used using ``AccountValueStorageBaseContainer/acceptAll(_:)-4csns``. TODO verify right reference!
    ///     If you directly call ``AccountValueKey/accept(_:_:)`` this will not be called and has no effect.
    /// - Returns:
    func final() -> Final
}


extension AccountValueVisitor {
    public func visit<Key: RequiredAccountValueKey>(_ key: Key.Type, _ value: Key.Value) {
        key.defaultAccept(self, value)
    }
}


extension AccountValueVisitor where Final == Void {
    /// Default `Void` implementation.
    public func final() {}
}


extension AccountValueKey {
    fileprivate static func defaultAccept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Value) {
        visitor.visit(Self.self, value)
    }
}
