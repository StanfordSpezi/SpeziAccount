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


    private var configuration: OrderedDictionary<ObjectIdentifier, AnyAccountValueConfigurationEntry>


    init(_ configuration: [ConfiguredAccountValue]) {
        // TODO we have configurations that must always be supplied
        //   => e.g. we assume userId??
        //   => based on the account service (e.g. userId + password!)

        self.configuration = configuration
            .map { $0.configuration }
            .reduce(into: [:]) { result, configuration in
                result[configuration.id] = configuration
            }
    }


    public subscript(_ key: any AccountValueKey.Type) -> AnyAccountValueConfigurationEntry? {
        configuration[key.id]
    }

    public subscript<Key: AccountValueKey>(_ key: Key.Type) -> AnyAccountValueConfigurationEntry? {
        configuration[Key.id]
    }

    public subscript<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> AnyAccountValueConfigurationEntry? {
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
    public typealias Index = OrderedDictionary<ObjectIdentifier, AnyAccountValueConfigurationEntry>.Index

    public var startIndex: Index {
        configuration.values.startIndex
    }

    public var endIndex: Index {
        configuration.values.endIndex
    }


    public func index(after index: Index) -> Index {
        configuration.values.index(after: index)
    }


    public subscript(position: Index) -> AnyAccountValueConfigurationEntry {
        configuration.values[position]
    }
}
