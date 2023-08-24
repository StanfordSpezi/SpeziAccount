//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


extension AccountKey {
    /// Accept a ``AccountValueVisitor`` on a single ``AccountKey`` metatype given an associated value.
    public static func accept<Visitor: AccountValueVisitor>(_ visitor: inout Visitor, _ value: Value) {
        if let requiredKey = self as? any RequiredAccountKey.Type {
            requiredKey.acceptRequired(&visitor, value)
        } else {
            visitor.visit(Self.self, value)
        }
    }

    /// Accept a ``AccountValueVisitor`` on a single ``AccountKey`` metatype given an associated value.
    public static func accept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Value) where Visitor: AnyObject {
        var visitor = visitor
        accept(&visitor, value)
    }

    /// Accept a ``AccountKeyVisitor`` on a single ``AccountKey`` metatype.
    public static func accept<Visitor: AccountKeyVisitor>(_ visitor: inout Visitor) {
        if let requiredKey = self as? any RequiredAccountKey.Type {
            requiredKey.acceptRequired(&visitor)
        } else {
            visitor.visit(Self.self)
        }
    }

    /// Accept a ``AccountKeyVisitor`` on a single ``AccountKey`` metatype.
    public static func accept<Visitor: AccountKeyVisitor>(_ visitor: Visitor) where Visitor: AnyObject {
        var visitor = visitor
        accept(&visitor)
    }
}

extension RequiredAccountKey {
    fileprivate static func acceptRequired<Visitor: AccountValueVisitor>(_ visitor: inout Visitor, _ value: Any) {
        guard let value = value as? Value else {
            preconditionFailure("Tried to visit \(Self.self) with value \(value) which is not of type \(Value.self)")
        }
        visitor.visit(Self.self, value)
    }

    fileprivate static func acceptRequired<Visitor: AccountKeyVisitor>(_ visitor: inout Visitor) {
        visitor.visit(Self.self)
    }
}
