//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// The collection of ``AccountKey``s that are required when using the associated ``AccountService``.
///
/// A ``AccountService`` may set this configuration to communicate that a certain set of ``AccountKey``s are
/// required to use the given account service. For example, a password-based account service defines the password
/// to be required using this configuration as the account value is only required in the context of using this specific
/// account service.
///
/// Access the configuration via the ``AccountServiceConfiguration/requiredAccountKeys``.
///
/// Below is an example configuration for a userid-password-based account service.
///
/// ```swift
/// let configuration = AccountServiceConfiguration(/* ... */) {
///     RequiredAccountKeys {
///         \.userId
///         \.password
///     }
/// }
public struct RequiredAccountKeys: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static let defaultValue = RequiredAccountKeys {
        \.userId // by default everyone requires the userId
    }

    fileprivate let keys: AccountKeyCollection


    /// Initialize new `RequiredAccountKeys` by providing the keys in the closure.
    /// - Parameter keys: The result builder closure providing the keys using `KeyPath` notation.
    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountKeyWithDescription]) {
        self.init(ofKeys: AccountKeyCollection(keys))
    }

    /// Initialize new `RequiredAccountKeys` by providing a instance of ``AccountKeyCollection``.
    /// - Parameter keys: The keys that are marked as required.
    public init(ofKeys keys: AccountKeyCollection) {
        self.keys = keys
    }
}


extension AccountServiceConfiguration {
    /// Access the required account keys of an ``AccountService``.
    public var requiredAccountKeys: AccountKeyCollection {
        storage[RequiredAccountKeys.self].keys
    }
}
