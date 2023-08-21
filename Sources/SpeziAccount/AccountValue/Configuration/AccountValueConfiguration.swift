//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections


public struct AccountValueConfiguration {
    public static let `default` = AccountValueConfiguration(.default)


    private var configuration: OrderedDictionary<ObjectIdentifier, any AccountKeyConfiguration>


    init(_ configuration: [ConfiguredAccountKey]) {
        self.configuration = configuration
            .map { $0.configuration }
            .reduce(into: [:]) { result, configuration in
                result[configuration.id] = configuration
            }
    }


    public subscript(_ key: any AccountKey.Type) -> (any AccountKeyConfiguration)? {
        configuration[key.id]
    }

    public subscript<Key: AccountKey>(_ key: Key.Type) -> (any AccountKeyConfiguration)? {
        configuration[Key.id]
    }

    public subscript<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> (any AccountKeyConfiguration)? {
        self[Key.self]
    }
}


extension Array where Element == ConfiguredAccountKey {
    public static let `default`: [ConfiguredAccountKey] = [
        .requires(\.userId),
        .requires(\.password),
        .requires(\.name),
        .collects(\.dateOfBirth),
        .collects(\.genderIdentity)
    ]
}


extension AccountValueConfiguration: Collection {
    public typealias Index = OrderedDictionary<ObjectIdentifier, any AccountKeyConfiguration>.Index

    public var startIndex: Index {
        configuration.values.startIndex
    }

    public var endIndex: Index {
        configuration.values.endIndex
    }


    public func index(after index: Index) -> Index {
        configuration.values.index(after: index)
    }


    public subscript(position: Index) -> any AccountKeyConfiguration {
        configuration.values[position]
    }
}
