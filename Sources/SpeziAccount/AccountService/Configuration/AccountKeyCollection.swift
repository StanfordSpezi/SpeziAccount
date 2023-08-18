//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


public struct AccountKeyCollection: Sendable {
    private let elements: [any AccountValueKey.Type]

    public init() {
        elements = []
    }

    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountValueKey.Type]) {
        self.elements = keys()
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


    public subscript(position: Int) -> any AccountValueKey.Type {
        elements[position]
    }
}


extension AccountKeyCollection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: any AccountValueKey.Type...) {
        self.elements = elements
    }
}
