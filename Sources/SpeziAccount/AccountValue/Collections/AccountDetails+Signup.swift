//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension AccountDetails {
    /// Checking account details against the user-defined requirements of the `AccountValueConfiguration`.
    ///
    /// Refer to the ``AccountValueConfiguration`` for more information.
    /// - Parameter configuration: The configured provided by the user (see ``Account/configuration``).
    /// - Throws: Throws potential ``AccountOperationError`` if requirements are not fulfilled.
    public func validateAgainstSignupRequirements(_ configuration: AccountValueConfiguration) throws {
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
