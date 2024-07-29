//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


struct AccountServiceConfigurationDetailsKey: DefaultProvidingKnowledgeSource {
    typealias Anchor = AccountAnchor
    typealias Value = AccountServiceConfiguration

    static let defaultValue = AccountServiceConfiguration(supportedKeys: .exactly(AccountKeyCollection()))
}


extension AccountDetails {
    /// The configuration of the account service that manages these account details.
    public var accountServiceConfiguration: AccountServiceConfiguration {
        get {
            storage[AccountServiceConfigurationDetailsKey.self]
        }
        set {
            storage[AccountServiceConfigurationDetailsKey.self] = newValue
        }
    }


    /// The type of user id stored in `UserIdKey`.
    ///
    /// This is a short-hand access to the value stored in the ``UserIdConfiguration`` which is part of the ``accountServiceConfiguration``.
    public var userIdType: UserIdType {
        accountServiceConfiguration.userIdConfiguration.idType
    }
}
