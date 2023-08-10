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
public struct AccountServiceConfiguration: Sendable {
    /// The underlying storage container you access to implement your own ``AccountServiceConfigurationKey``.
    public let storage: AccountServiceConfigurationStorage
    

    /// Initialize a new configuration by just providing the required ones.
    /// - Parameter name: The name of the ``AccountService``. Refer to ``AccountServiceName`` for more information.
    public init(name: LocalizedStringResource) {
        self.storage = Self.createStorage(name: name)
    }

    /// Initialize a new configuration by providing additional configurations.
    /// - Parameters:
    ///   - name: The name of the ``AccountService``. Refer to ``AccountServiceName`` for more information.
    ///   - configuration: A ``AccountServiceConfigurationBuilder`` to provide a list of ``AccountServiceConfigurationKey``s.
    public init(
        name: LocalizedStringResource,
        @AccountServiceConfigurationBuilder configuration: () -> [any AccountServiceConfigurationKey]
    ) {
        self.storage = Self.createStorage(name: name, configuration: configuration())
    }

    // TODO annotate supported signup requirements, to check if anything is unsupported?
    //      (might be that an account service supports everything) => required ting to specify!
    //    => enum .all, supported(requirements)
    private static func createStorage(
        name: LocalizedStringResource, // TODO second required parameter: supported account values?
        configuration: [any AccountServiceConfigurationKey] = []
    ) -> AccountServiceConfigurationStorage {
        var storage = AccountServiceConfigurationStorage()
        storage[AccountServiceName.self] = AccountServiceName(name)

        for configuration in configuration {
            configuration.store(into: &storage)
        }

        return storage
    }
}
