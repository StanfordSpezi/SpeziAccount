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
    enum IncludeCollectedType {
        case onlyRequired
        case includeCollected
        case includeCollectedAtLeastOneRequired
    }

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

    func allCategorizedForDisplay(
        filteredBy filter: Set<AccountKeyRequirement>? = nil
    ) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        // swiftlint:disable:previous discouraged_optional_collection
        let requiredOptions: AccountKeyOptions = if let filter, !filter.isDisjoint(with: [.required, .collected]) {
            // if we are filtering for requirements that do not allow for `mutable` to be missing, we need to enforce and filter for that
            [.display, .mutable]
        } else {
            .display
        }

        let collection: some Collection<any AccountKeyConfiguration> = if let filter {
            self.lazy.filter { configuration in
                configuration.key.options.contains(requiredOptions)
                    && filter.contains(configuration.requirement)
            }
        } else {
            self.lazy.filter { configuration in
                configuration.key.options.contains(requiredOptions)
            }
        }

        return collection.reduce(into: [:]) { result, configuration in
            result[configuration.key.category, default: []] += [configuration.key]
        }
    }

    func missingRequiredKeys(
        for details: AccountDetails,
        _ includeCollected: IncludeCollectedType = .onlyRequired,
        ignoring: [any AccountKey.Type] = []
    ) -> [any AccountKey.Type] {
        let keysPresent = Set(details.keys.map { ObjectIdentifier($0) })
            .union(Set(ignoring.map { ObjectIdentifier($0) }))

        let missingKeys = filter { entry in
            entry.key.options.contains([.display, .mutable]) // do not consider details that are not capable of being displayed or mutated
                && entry.key.category != .credentials // generally, don't collect credentials!
                && (entry.requirement == .required || entry.requirement == .collected) // not interested in supported keys
                && !keysPresent.contains(ObjectIdentifier(entry.key)) // missing on the current details
        }

        let result = switch includeCollected {
        case .includeCollectedAtLeastOneRequired:
            if missingKeys.contains(where: { $0.requirement == .required }) {
                missingKeys
            } else {
                missingKeys.filter { entry in
                    entry.requirement == .required
                }
            }
        case .onlyRequired:
            missingKeys.filter { entry in
                entry.requirement == .required
            }
        case .includeCollected:
            missingKeys
        }

        return result.map { $0.key }
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
