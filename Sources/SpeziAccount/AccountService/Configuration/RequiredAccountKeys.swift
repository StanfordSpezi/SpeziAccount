//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// The collection of ``AccountKey``s that are required to use the associated ``AccountService``.
///
/// A ``AccountService`` may set this configuration to communicate that a certain set of ``AccountKey``s are
/// required to be configured in the ``AccountValueConfiguration`` provided in the ``AccountConfiguration`` in
/// order to user the account service.
///
/// Upon startup, `SpeziAccount` automatically verifies that the user-configured account values match the expectation
/// set by the ``AccountService`` through this configuration option.
///
/// Access the configuration via the ``AccountServiceConfiguration/requiredAccountKeys``.
///
/// Below is an example on how to provide this option.
///
/// ```swift
/// let configuration = AccountServiceConfiguration(/* ... */) {
///     RequiredAccountKeys {
///         \.userId
///         \.password
///     }
/// }
public struct RequiredAccountKeys: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static let defaultValue = RequiredAccountKeys(ofKeys: .init()) // TODO UserId + Password is always required for the UserId account service

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
