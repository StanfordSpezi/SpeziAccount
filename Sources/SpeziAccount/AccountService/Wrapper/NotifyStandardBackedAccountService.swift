//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


actor NotifyStandardBackedAccountService<Service: AccountService, Standard: AccountNotifyConstraint>: AccountService, _StandardBacked {
    @Dependency private var account: Account

    let accountService: Service
    let standard: Standard
    
    nonisolated var configuration: AccountServiceConfiguration {
        accountService.configuration
    }


    init(service accountService: Service, standard: Standard) {
        self.accountService = accountService
        self.standard = standard
    }


    func delete() async throws {
        try await standard.deletedAccount()
        try await accountService.delete()
    }
}
