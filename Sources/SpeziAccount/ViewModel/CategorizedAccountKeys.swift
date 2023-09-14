//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections


struct CategorizedAccountKeys {
    private var accountKeys: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>

    var keys: [any AccountKey.Type] {
        accountKeys.values.reduce(into: []) { result, keys in
            result.append(contentsOf: keys)
        }
    }

    init() {
        accountKeys = [:]
    }

    mutating func append(_ value: any AccountKey.Type) {
        accountKeys[value.category, default: []]
            .append(value)
    }

    func contains(_ value: any AccountKey.Type) -> Bool {
        accountKeys[value.category, default: []]
            .contains(where: { $0.id == value.id })
    }

    func index(of value: any AccountKey.Type) -> Int? {
        accountKeys[value.category, default: []]
            .firstIndex(where: { $0.id == value.id })
    }

    @discardableResult
    mutating func remove(at index: Int, for category: AccountKeyCategory) -> any AccountKey.Type {
        let result = accountKeys[category, default: []]
            .remove(at: index)

        return result
    }
}
