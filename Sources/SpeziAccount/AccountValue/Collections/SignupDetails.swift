//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct SignupDetails: Sendable, AccountValues {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise

    public let storage: AccountStorage


    public init(from storage: AccountStorage) {
        self.storage = storage
    }


    fileprivate func validateRequirements(checking configuration: AccountValueConfiguration) throws {
        let missing = configuration.filter { configuration in
            configuration.requirement == .required && !self.contains(configuration.key)
        }

        if !missing.isEmpty {
            let keyNames = missing.map { $0.keyPathDescription }

            LoggerKey.defaultValue.warning("\(keyNames) was/were required to be provided but wasn't/weren't provided!")
            throw AccountValueConfigurationError.missingAccountValue(keyNames)
        }
    }
}


extension AccountValuesBuilder where Container == SignupDetails {
    public func build(
        checking configuration: AccountValueConfiguration
    ) throws -> Container {
        let details = self.build()

        try details.validateRequirements(checking: configuration)

        return details
    }
}
