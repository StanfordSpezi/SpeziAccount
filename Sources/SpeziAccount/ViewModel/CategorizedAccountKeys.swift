//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections


struct CategorizedAccountKeys {
    private var addedAccountValues: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]>

    var values: [any AccountValueKey.Type] {
        addedAccountValues.values.reduce(into: []) { result, keys in
            result.append(contentsOf: keys)
        }
    }

    init() {
        addedAccountValues = [:]
    }

    mutating func append(_ value: any AccountValueKey.Type) {
        addedAccountValues[value.category, default: []]
            .append(value)
    }

    func contains(_ value: any AccountValueKey.Type) -> Bool {
        addedAccountValues[value.category, default: []]
            .contains(where: { $0.id == value.id })
    }

    func index(of value: any AccountValueKey.Type) -> Int? {
        addedAccountValues[value.category, default: []]
            .firstIndex(where: { $0.id == value.id })
    }

    @discardableResult
    mutating func remove(at index: Int, for category: AccountValueCategory) -> any AccountValueKey.Type {
        let result = addedAccountValues[category, default: []]
            .remove(at: index)

        return result
    }
}
