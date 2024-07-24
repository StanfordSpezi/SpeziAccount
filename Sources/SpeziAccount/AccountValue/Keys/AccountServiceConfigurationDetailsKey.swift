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
    typealias Value = AccountServiceConfiguration // TODO: no check that this is Sendable!

    static let defaultValue = AccountServiceConfiguration(supportedKeys: .exactly(AccountKeyCollection()))
}


extension AccountDetails {
    /// The configuration of the account service that manages these account details.
    public var accountServiceConfiguration: AccountServiceConfiguration {
        storage[AccountServiceConfigurationDetailsKey.self]
    }


    public var userIdType: UserIdType {
/*
 // TODO: reuse old-docs
 -    /// Short-hand access to the ``UserIdType`` stored in the ``UserIdConfiguration`` of
 -    /// the ``AccountServiceConfiguration`` of the currently active ``AccountService``.
 */
        accountServiceConfiguration.userIdConfiguration.idType
    }
}