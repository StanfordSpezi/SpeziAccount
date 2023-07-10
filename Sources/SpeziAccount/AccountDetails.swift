//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountValueKey`` for a list of bundled `AccountValueKey`s.
public struct AccountDetails: Sendable, ModifiableAccountValueStorageContainer {
    // TODO think about modification?
    public typealias Builder = AccountValueStorageBuilder<Self>

    // This property is accessible once
    @AccountReference private var account: Account

    public var storage: AccountValueStorage

    // we just store the id as we would otherwise impose `Sendable` requirements on the AccountService
    internal let accountServiceId: ObjectIdentifier

    public var accountService: any AccountService {
        guard let service = account.mappedAccountServices[accountServiceId] else {
            fatalError("AccountDetails stored an AccountService Id that wasn't present in the Account instance!")
        }

        return service
    }

    init<Service: AccountService>(storage: AccountValueStorage, owner accountService: Service) {
        self.storage = storage

        // patch the storage to make sure we make sure to not expose the plaintext password
        self.storage.contents[ObjectIdentifier(PasswordAccountValueKey.self)] = nil
        self.accountServiceId = accountService.id
    }
}
