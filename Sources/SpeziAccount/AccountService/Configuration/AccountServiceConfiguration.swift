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


public typealias AccountServiceConfigurationStorage = ValueRepository<AccountServiceConfiguration.StorageAnchor>


public struct AccountServiceConfiguration {
    public struct StorageAnchor: RepositoryAnchor {} // TODO placement?

    public let storage: AccountServiceConfigurationStorage
    

    public init(name: LocalizedStringResource) {
        self.storage = Self.createStorage(name: name)
    }

    public init(
        name: LocalizedStringResource,
        @AccountServiceConfigurationBuilder configuration: () -> [any AccountServiceConfigurationKey]
    ) {
        self.storage = Self.createStorage(name: name, configuration: configuration())
    }

    // TODO annoate supported signup requirements, to check if anything is unsupported?
    //      (might be that an account service supports everything) => required ting to specify!
    //    => enum .all, supported(requirements)
    private static func createStorage(
        name: LocalizedStringResource, // TODO second required parameter: supported account values?
        configuration: [any AccountServiceConfigurationKey] = []
    ) -> AccountServiceConfigurationStorage {
        var storage = AccountServiceConfigurationStorage()
        storage[AccountServiceName.self] = AccountServiceName(name)

        for configuration in configuration {
            configuration.setInto(repository: &storage)
        }

        return storage
    }
}
