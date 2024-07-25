//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//



@dynamicMemberLookup
public struct SimpleBuilder { // TODO: move the whole thing somewhere!
    // TODO: why do we have the builder thing, if we can just mutate the details themselves?
    // TODO: => if we do the subscript thing, we could do an @Entry like macro! (bit weird from a docs perspective but okay!)

    // TODO: if we make AccountDetails do @dynamicMemberLookup, we could do an @Entry like macro! (bit weird from a docs perspective but okay!)
    private let builder: AccountValuesBuilder

    init() {
        self.builder = AccountValuesBuilder()
    }

    fileprivate func build() -> AccountDetails {
        builder.build()
    }

    public subscript<Key: AccountKey>(dynamicMember keyPath: KeyPath<AccountKeys, Key.Type>) -> Key.Value? {
        get {
            builder.get(Key.self)
        }
        nonmutating set {
            builder.set(Key.self, value: newValue)
        }
    }

    public func add(contentsOf values: AccountDetails, merge: Bool = false) {
        builder.merging(values, allowOverwrite: merge)
    }

    public func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value?) {
        builder.set(key, value: value)
    }

    public func removeAll(_ keys: [any AccountKey.Type]) {
        builder.remove(all: keys)
    }
}


extension AccountDetails {
    public static func build(_ build: (SimpleBuilder) throws -> Void) rethrows -> Self {
        let builder = SimpleBuilder()
        try build(builder) // TODO: we could pass as inout and build with mutating?
        // TODO: make other building things private/internal!
        return builder.build()
    }

    public static func build(_ build: @Sendable (SimpleBuilder) async throws -> Void) async rethrows -> Self {
        // TODO: swift 6 syntax avoids sendable problems!: isolation: isolated (any Actor)? = #isolation,
        let builder = SimpleBuilder()
        try await build(builder)
        return builder.build()
    }
}
