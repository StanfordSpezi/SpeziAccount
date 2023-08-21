//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public protocol AccountKeyWithDescription: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype Key: AccountKey

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


public struct AccountKeyCollection: Sendable, AcceptingAccountKeyVisitor {
    private let elements: [any AccountKeyWithDescription]


    public init() {
        self.elements = []
    }

    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountKeyWithDescription]) {
        self.elements = keys()
    }


    public func acceptAll<Visitor: AccountKeyVisitor>(_ visitor: Visitor) -> Visitor.Final {
        self
            .map { $0.key }
            .acceptAll(visitor)
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
