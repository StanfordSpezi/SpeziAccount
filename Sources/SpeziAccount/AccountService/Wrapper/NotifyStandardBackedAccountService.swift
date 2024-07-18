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
    @Dependency var accountServiceWorkaround: [any Module] // TODO: wtf does the init from @Dependency not work anymore!

    let accountService: Service
    let standard: Standard
    
    nonisolated var configuration: AccountServiceConfiguration {
        accountService.configuration
    }

    nonisolated var viewStyle: Service.ViewStyle {
        accountService.viewStyle
    }


    init(service accountService: Service, standard: Standard) {
        self.accountService = accountService
        self._accountServiceWorkaround = Dependency(using: DependencyCollection { accountService }) // TODO: make autoclosure
        self.standard = standard
    }


    func delete() async throws {
        try await standard.deletedAccount()
        try await accountService.delete()
    }
}


extension NotifyStandardBackedAccountService: EmbeddableAccountService where Service: EmbeddableAccountService {}

extension NotifyStandardBackedAccountService: UserIdPasswordAccountService where Service: UserIdPasswordAccountService {}

extension NotifyStandardBackedAccountService: IdentityProvider where Service: IdentityProvider {}
