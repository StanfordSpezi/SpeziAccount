//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public protocol AcceptingAccountKeyVisitor {
    func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: Visitor) -> Visitor.Final
}


public protocol AccountKeyVisitor {
    associatedtype Final = Void

    func visit<Key: AccountKey>(_ key: Key.Type)

    func visit<Key: RequiredAccountKey>(_ key: Key.Type)

    func final() -> Final
}


extension AccountKeyVisitor {
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
    public func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: Visitor) -> Visitor.Final {
        for key in self {
            key.anyAccept(visitor)
        }

        return visitor.final()
    }
}


extension Array: AcceptingAccountKeyVisitor where Element == any AccountKey.Type {}
