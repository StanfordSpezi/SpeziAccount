//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public protocol AccountValueVisitor {
    associatedtype FinalResult = Void

    func visit<Key: AccountValueKey>(_ key: Key.Type, _ value: Key.Value)

    func visit<Key: RequiredAccountValueKey>(_ key: Key.Type, _ value: Key.Value)

    func buildFinal() -> FinalResult
}


extension AccountValueVisitor where FinalResult == Void {
    public func buildFinal() {}
}


extension AccountValueVisitor {
    public func visit<Key: RequiredAccountValueKey>(_ key: Key.Type, _ value: Key.Value) {
        key.defaultAccept(self, value)
    }
}


extension AccountValueKey {
    fileprivate static func defaultAccept<Visitor: AccountValueVisitor>(_ visitor: Visitor, _ value: Value) {
        visitor.visit(Self.self, value)
    }
}
