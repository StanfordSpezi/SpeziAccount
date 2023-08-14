//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct SignupDetails: Sendable, AccountValueStorageContainer {
    public typealias Builder = AccountValueStorageBuilder<Self>

    public let storage: AccountValueStorage


    fileprivate init(storage: AccountValueStorage) {
        self.storage = storage
    }


    fileprivate func validateRequirements(checking configuration: AccountValueConfiguration) throws {
        for configuration in configuration where !configuration.isContained(in: storage) {
            LoggerKey.defaultValue.warning("\(configuration.description) was required to be provided but weren't provided!")
            throw AccountValueConfigurationError.missingAccountValue(configuration.description)
        }
    }
}


extension AccountValueStorageBuilder where Container == SignupDetails {
    public func build(
        checking configuration: AccountValueConfiguration? = nil
    ) throws -> Container {
        let details = SignupDetails(storage: self.storage)

        if let configuration {
            try details.validateRequirements(checking: configuration)
        }

        return details
    }
}
