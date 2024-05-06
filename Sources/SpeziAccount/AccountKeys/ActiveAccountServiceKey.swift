//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A `KnowledgeSource` to access the ``AccountService`` associated with the ``AccountDetails``.
public struct ActiveAccountServiceKey: KnowledgeSource {
    public typealias Anchor = AccountAnchor
    public typealias Value = any AccountService
}


extension AccountDetails {
    /// Access the ``AccountService`` associated with the ``AccountDetails``.
    ///
    /// - Note: You should not assume the type of the active ``AccountService``. Depending on the configuration,
    ///     the active ``AccountService`` might be wrapped into other account service types and, therefore,
    ///     type cast will fail unexpectedly.
    ///     An ``AccountService`` might communicate extra functionality using the ``AccountServiceConfiguration``.
    public var accountService: any AccountService {
        guard let accountService = storage[ActiveAccountServiceKey.self] else {
            fatalError("""
                       The active Account Service is not present in the AccountDetails storage. \
                       This could happen, e.g., if you did not properly set up your PreviewProvider.
                       """)
        }

        return accountService
    }
}


extension AccountDetails {
    /// Short-hand access to the ``AccountServiceConfiguration``.
    public var accountServiceConfiguration: AccountServiceConfiguration {
        accountService.configuration
    }

    /// Short-hand access to the ``UserIdType`` stored in the ``UserIdConfiguration`` of
    /// the ``AccountServiceConfiguration`` of the currently active ``AccountService``.
    public var userIdType: UserIdType {
        accountService.configuration.userIdConfiguration.idType
    }
}
