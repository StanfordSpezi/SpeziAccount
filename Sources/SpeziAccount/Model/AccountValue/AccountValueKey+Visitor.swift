//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

// MARK: - Container

extension AccountValueStorageBaseContainer {
    public func acceptAll<Visitor: AccountValueVisitor>(_ visitor: Visitor) -> Visitor.Final {
        for entry in storage {
            // not all knowledge sources are `AccountValueKey`
            guard let accountKey = entry.anySource as? any AccountValueKey.Type else {
                continue
            }

            accountKey.anyAccept(visitor, entry.anyValue)
        }

        return visitor.final()
    }
}


extension Array: AcceptingAccountKeyVisitor where Element == any AccountValueKey.Type {}

// MARK: - Account Key

extension AccountValueKey {
    public static func accept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Value) {
        if let requiredKey = self as? any RequiredAccountValueKey.Type {
            requiredKey.acceptRequired(visitor, value)
        } else {
            visitor.visit(Self.self, value)
        }
    }

    public static func accept<Visitor: AccountKeyVisitor>(_ visitor: Visitor) {
        if let requiredKey = self as? any RequiredAccountValueKey.Type {
            requiredKey.acceptRequired(visitor)
        } else {
            visitor.visit(Self.self)
        }
    }

    // use by acceptAll
    fileprivate static func anyAccept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Any) {
        guard let value = value as? Value else {
            preconditionFailure("Tried to visit \(Self.self) with value \(value) which is not of type \(Value.self)")
        }

        accept(visitor, value)
    }
}

extension RequiredAccountValueKey {
    fileprivate static func acceptRequired<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Any) {
        guard let value = value as? Value else {
            preconditionFailure("Tried to visit \(Self.self) with value \(value) which is not of type \(Value.self)")
        }
        visitor.visit(Self.self, value)
    }

    fileprivate static func acceptRequired<Visitor: AccountKeyVisitor>(_ visitor: Visitor) {
        visitor.visit(Self.self)
    }
}
