//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections


/// The user-defined configuration of account values that all user accounts need to support.
///
/// Using a ``AccountValueConfiguration`` instance, the user can defined what ``AccountKey``s are required,
/// collected at signup or generally supported. You configure them by supplying an array of ``ConfiguredAccountKey``s.
///
/// A configuration instance is created using ``AccountConfiguration`` and stored at ``Account/configuration``.
@dynamicMemberLookup
public struct AccountValueConfiguration {
    /// The default set of ``ConfiguredAccountKey``s that `SpeziAccount` provides.
    public static let `default` = AccountValueConfiguration(.default)


    private var configuration: OrderedDictionary<ObjectIdentifier, any AccountKeyConfiguration>

    /// The collection of keys stored in the configuration.
    public var keys: AccountKeyCollection {
        AccountKeyCollection(configuration.values.map { $0.keyWithDescription })
    }


    init(_ configuration: [ConfiguredAccountKey]) {
        self.configuration = configuration
            .map { $0.configuration }
            .reduce(into: [:]) { result, configuration in
                result[configuration.id] = configuration
            }
    }


    func all(filteredBy filter: [AccountKeyRequirement]? = nil) -> [any AccountKey.Type] {
        // swiftlint:disable:previous discouraged_optional_collection

        if let filter {
            return self
                .filter { configuration in
                    filter.contains(configuration.requirement)
                }
                .map { $0.key }
        } else {
            return configuration.values.map { $0.key }
        }
    }

    func allCategorized(filteredBy filter: [AccountKeyRequirement]? = nil) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        // swiftlint:disable:previous discouraged_optional_collection
        if let filter {
            return self.reduce(into: [:]) { result, configuration in
                guard filter.contains(configuration.requirement) else {
                    return
                }

                result[configuration.key.category, default: []] += [configuration.key]
            }
        } else {
            return self.reduce(into: [:]) { result, configuration in
                result[configuration.key.category, default: []] += [configuration.key]
            }
        }
    }

    func missingRequiredKeys(for details: AccountDetails, includeCollected: Bool = false) -> [any AccountKey.Type] {
        let accountKeyIds = Set(details.keys.map { ObjectIdentifier($0) })

        return self
            .all(filteredBy: includeCollected ? [.required, .collected] : [.required])
            .filter { $0.category != .credentials } // don't collect credentials!
            .filter { key in
                !accountKeyIds.contains(ObjectIdentifier(key))
            }
    }


    /// Retrieve the configuration for a given type-erased ``AccountKey``.
    /// - Parameter key: The account key to query.
    /// - Returns: The configuration for a given ``AccountKey`` if it exists.
    public subscript(_ key: any AccountKey.Type) -> (any AccountKeyConfiguration)? {
        configuration[key.id]
    }

    /// Retrieve the configuration for a given ``AccountKey``.
    /// - Parameter key: The account key to query.
    /// - Returns: The configuration for a given ``AccountKey`` if it exists.
    public subscript<Key: AccountKey>(_ key: Key.Type) -> (any AccountKeyConfiguration)? {
        configuration[Key.id]
    }

    /// Retrieve the configuration for a given ``AccountKey`` using `KeyPath` notation.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: The configuration for a given ``AccountKey`` if it exists.
    public subscript<Key: AccountKey>(dynamicMember keyPath: KeyPath<AccountKeys, Key.Type>) -> (any AccountKeyConfiguration)? {
        self[Key.self]
    }
}


extension Array where Element == ConfiguredAccountKey {
    /// The default array of ``ConfiguredAccountKey``s that `SpeziAccount` provides.
    public static let `default`: [ConfiguredAccountKey] = [
        .requires(\.userId),
        .requires(\.password),
        .requires(\.name),
        .collects(\.dateOfBirth),
        .collects(\.genderIdentity)
    ]
}


extension AccountValueConfiguration: Sendable {}


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


extension AccountValueConfiguration: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: ConfiguredAccountKey...) {
        self.init(elements)
    }
}
