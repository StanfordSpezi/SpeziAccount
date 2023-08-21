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


    private var configuration: OrderedDictionary<ObjectIdentifier, any AnyAccountValueConfigurationEntry>


    init(_ configuration: [ConfiguredAccountValue]) {
        self.configuration = configuration
            .map { $0.configuration }
            .reduce(into: [:]) { result, configuration in
                result[configuration.id] = configuration
            }
    }


    public subscript(_ key: any AccountValueKey.Type) -> (any AnyAccountValueConfigurationEntry)? {
        configuration[key.id]
    }

    public subscript<Key: AccountValueKey>(_ key: Key.Type) -> (any AnyAccountValueConfigurationEntry)? {
        configuration[Key.id]
    }

    public subscript<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> (any AnyAccountValueConfigurationEntry)? {
        self[Key.self]
    }
}


extension Array where Element == ConfiguredAccountValue {
    public static let `default`: [ConfiguredAccountValue] = [
        .requires(\.userId),
        .requires(\.password),
        .requires(\.name),
        .collects(\.dateOfBirth),
        .collects(\.genderIdentity)
    ]
}


extension AccountValueConfiguration: Collection {
    public typealias Index = OrderedDictionary<ObjectIdentifier, any AnyAccountValueConfigurationEntry>.Index

    public var startIndex: Index {
        configuration.values.startIndex
    }

    public var endIndex: Index {
        configuration.values.endIndex
    }


    public func index(after index: Index) -> Index {
        configuration.values.index(after: index)
    }


    public subscript(position: Index) -> any AnyAccountValueConfigurationEntry {
        configuration.values[position]
    }
}
