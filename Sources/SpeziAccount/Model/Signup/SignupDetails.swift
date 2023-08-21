//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct SignupDetails: Sendable, AccountValueStorageContainer {
    public let storage: AccountValueStorage


    public init(from storage: AccountValueStorage) {
        self.storage = storage
    }


    fileprivate func validateRequirements(checking configuration: AccountValueConfiguration) throws {
        for configuration in configuration where configuration.requirement == .required && !configuration.isContained(in: self) {
            LoggerKey.defaultValue.warning("\(configuration.description) was required to be provided but weren't provided!")
            throw AccountValueConfigurationError.missingAccountValue(configuration.description)
        }
    }
}


extension AccountValueStorageBuilder where Container == SignupDetails {
    public func build(
        checking configuration: AccountValueConfiguration
    ) throws -> Container {
        let details = self.build()

        try details.validateRequirements(checking: configuration)

        return details
    }
}
