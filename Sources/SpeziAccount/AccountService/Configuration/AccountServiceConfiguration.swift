//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SwiftUI


/// A `RepositoryAnchor` for ``AccountServiceConfigurationStorage``.
public struct AccountServiceConfigurationStorageAnchor: RepositoryAnchor, Sendable {}


/// A `ValueRepository` that is anchored to ``AccountServiceConfigurationStorageAnchor``.
///
/// This is the underlying storage type for the ``AccountServiceConfiguration`` to store instances of ``AccountServiceConfigurationKey``.
public typealias AccountServiceConfigurationStorage = ValueRepository<AccountServiceConfigurationStorageAnchor>


/// Configuration options that are provided by an ``AccountService``.
///
/// A instance of this type is required to be provided by every ``AccountService``. It is used to
/// set and communicate certain configuration options of the account service to the UI components that
/// represent the account service (e.g., determining the type of userId through ``UserIdConfiguration`` or
/// providing ``ValidationRule``s for a field through the ``FieldValidationRules`` configuration).
///
/// For more information on how to provide custom configuration options, refer to the documentation of
/// ``AccountServiceConfigurationKey``.
///
/// ## Topics
///
/// ### Infrastructure
///
/// - ``AccountServiceConfigurationBuilder``
/// - ``AccountServiceConfigurationKey``
public struct AccountServiceConfiguration: Sendable {
    /// The underlying storage container you access to implement your own ``AccountServiceConfigurationKey``.
    public let storage: AccountServiceConfigurationStorage
    

    /// Initialize a new configuration by just providing the required ones.
    /// - Parameters:
    ///   - name: The name of the ``AccountService``. Refer to ``AccountServiceName`` for more information.
    ///   - supportedKeys: The set of ``SupportedAccountKeys`` the ``AccountService`` is capable of storing itself.
    ///     If ``SupportedAccountKeys/exactly(_:)`` is chosen, the user is responsible of providing a ``AccountStorageStandard``
    ///     that is capable of handling all non-supported ``AccountKey``s.
    public init(name: LocalizedStringResource, supportedKeys: SupportedAccountKeys) {
        self.storage = Self.createStorage(name: name, supportedKeys: supportedKeys)
    }

    /// Initialize a new configuration by providing additional configurations.
    /// - Parameters:
    ///   - name: The name of the ``AccountService``. Refer to ``AccountServiceName`` for more information.
    ///   - supportedKeys: The set of ``SupportedAccountKeys`` the ``AccountService`` is capable of storing itself.
    ///     If ``SupportedAccountKeys/exactly(_:)`` is chosen, the user is responsible of providing a ``AccountStorageStandard``
    ///     that is capable of handling all non-supported ``AccountKey``s.
    ///   - configuration: A ``AccountServiceConfigurationBuilder`` to provide a list of ``AccountServiceConfigurationKey``s.
    public init(
        name: LocalizedStringResource,
        supportedKeys: SupportedAccountKeys,
        @AccountServiceConfigurationBuilder configuration: () -> [any AccountServiceConfigurationKey]
    ) {
        self.storage = Self.createStorage(name: name, supportedKeys: supportedKeys, configuration: configuration())
    }


    private static func createStorage(
        name: LocalizedStringResource,
        supportedKeys: SupportedAccountKeys,
        configuration: [any AccountServiceConfigurationKey] = []
    ) -> AccountServiceConfigurationStorage {
        var storage = AccountServiceConfigurationStorage()
        storage[AccountServiceName.self] = AccountServiceName(name)
        storage[SupportedAccountKeys.self] = supportedKeys

        for configuration in configuration {
            configuration.store(into: &storage)
        }

        return storage
    }
}
