//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/*
@dynamicMemberLookup
public class SimpleBuilder { // TODO: move the whole thing somewhere!
    // TODO: why do we have the builder thing, if we can just mutate the details themselves?
    // TODO: => if we do the subscript thing, we could do an @Entry like macro! (bit weird from a docs perspective but okay!)

    // TODO: if we make AccountDetails do @dynamicMemberLookup, we could do an @Entry like macro! (bit weird from a docs perspective but okay!)
    private var details: AccountDetails

    init() {
        self.details = AccountDetails()
    }

    // TODO: are builders even even still required? moving dynamic member lookup to details, it should not be required (except for visitor pattern?)

    fileprivate func build() -> AccountDetails {
        details
    }

    public subscript<Key: AccountKey>(dynamicMember keyPath: KeyPath<AccountKeys, Key.Type>) -> Key.Value? {
        get {
            details.storage.get(Key.self)
        }
        set {
            details.storage.set(Key.self, value: newValue)
        }
    }

    public func add(contentsOf values: AccountDetails, merge: Bool = false) {
        details.add(contentsOf: values, merge: merge)
    }

    public func set<Key: AccountKey>(_ key: Key.Type, value: Key.Value?) {
        details.storage.set(key, value: value)
    }

    public func removeAll(_ keys: [any AccountKey.Type]) {
        details.removeAll(keys)
    }
}
*/


extension AccountDetails {
    public static func build(_ build: (inout AccountDetails) throws -> Void) rethrows -> Self {
        var details = AccountDetails()
        try build(&details)
        // TODO: make other building things private/internal!
        return details
    }

    public static func build(_ build: @Sendable (inout AccountDetails) async throws -> Void) async rethrows -> Self {
        // TODO: swift 6 syntax avoids sendable problems!: isolation: isolated (any Actor)? = #isolation,
        var details = AccountDetails()
        try await build(&details)
        return details
    }
}
