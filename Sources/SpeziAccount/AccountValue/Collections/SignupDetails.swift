//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// Set of ``AccountValues`` that were collected at signup to create a new user account.
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
            throw AccountOperationError.missingAccountValue(keyNames)
        }
    }
}


extension AccountValuesBuilder where Values == SignupDetails {
    /// Building new ``SignupDetails`` while checking it's contents against the user-defined ``AccountValueConfiguration``.
    /// - Parameter configuration: The configured provided by the user (see ``Account/configuration``).
    /// - Returns: The built ``SignupDetails``.
    /// - Throws: Throws potential ``AccountOperationError`` if requirements are not fulfilled.
    public func build(
        checking configuration: AccountValueConfiguration
    ) throws -> Values {
        let details = self.build()

        try details.validateRequirements(checking: configuration)

        return details
    }
}
