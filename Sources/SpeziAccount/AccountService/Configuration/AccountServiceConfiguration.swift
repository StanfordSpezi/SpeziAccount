//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation
import SwiftUI


/// A `RepositoryAnchor` for ``AccountServiceConfigurationStorage``.
public struct AccountServiceConfigurationStorageAnchor: RepositoryAnchor, Sendable {}


/// A `ValueRepository` that is anchored to ``AccountServiceConfigurationStorageAnchor``.
///
/// This is the underlying storage type for the ``AccountServiceConfiguration`` to store instances of ``AccountServiceConfigurationKey``.
public typealias AccountServiceConfigurationStorage = SendableValueRepository<AccountServiceConfigurationStorageAnchor>


/// Configuration options that are provided by an `AccountService`.
///
/// A instance of this type is required to be provided by every ``AccountService``. It is used to
/// set and communicate certain configuration options of the account service to the UI components that
/// represent the account service (e.g., determining the type of userId through ``UserIdConfiguration`` or
/// providing `ValidationRule`s for a field through the ``FieldValidationRules`` configuration).
///
/// For more information on how to provide custom configuration options, refer to the documentation of
/// ``AccountServiceConfigurationKey``.
///
/// ## Topics
///
/// ### Retrieving configuration
/// Below is a list of builtin configuration options.
///
/// - ``userIdConfiguration``
/// - ``fieldValidationRules(for:)-28x74``
/// - ``fieldValidationRules(for:)-w2n2``
///
/// ### Result Builder
/// - ``AccountServiceConfigurationKey``
/// - ``AccountServiceConfigurationBuilder``
///
/// ### Shared Repository
/// - ``AccountServiceConfigurationStorageAnchor``
/// - ``AccountServiceConfigurationStorage``
public struct AccountServiceConfiguration: Sendable {
    /// The underlying storage container you access to implement your own ``AccountServiceConfigurationKey``.
    public let storage: AccountServiceConfigurationStorage
    

    /// Initialize a new configuration by just providing the required ones.
    /// - Parameters:
    ///   - supportedKeys: The set of ``SupportedAccountKeys`` the ``AccountService`` is capable of storing itself.
    ///     If ``SupportedAccountKeys/exactly(_:)`` is chosen, the user is responsible of providing a ``AccountStorageProvider``
    ///     that is capable of handling all non-supported ``AccountKey``s.
    public init(supportedKeys: SupportedAccountKeys) {
        self.storage = Self.createStorage(supportedKeys: supportedKeys)
    }

    /// Initialize a new configuration by providing additional configurations.
    /// - Parameters:
    ///   - supportedKeys: The set of ``SupportedAccountKeys`` the ``AccountService`` is capable of storing itself.
    ///     If ``SupportedAccountKeys/exactly(_:)`` is chosen, the user is responsible of providing a ``AccountStorageProvider``
    ///     that is capable of handling all non-supported ``AccountKey``s.
    ///   - configuration: A ``AccountServiceConfigurationBuilder`` to provide a list of ``AccountServiceConfigurationKey``s.
    public init(
        supportedKeys: SupportedAccountKeys,
        @AccountServiceConfigurationBuilder configuration: () -> [any AccountServiceConfigurationKey]
    ) {
        self.storage = Self.createStorage(supportedKeys: supportedKeys, configuration: configuration())
    }


    private static func createStorage(
        supportedKeys: SupportedAccountKeys,
        configuration: [any AccountServiceConfigurationKey] = []
    ) -> AccountServiceConfigurationStorage {
        var storage = AccountServiceConfigurationStorage()
        storage[SupportedAccountKeys.self] = supportedKeys

        for configuration in configuration {
            configuration.store(into: &storage)
        }

        return storage
    }
}
