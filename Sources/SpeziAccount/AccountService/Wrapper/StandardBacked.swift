//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// Internal marker protocol to determine what ``AccountService`` require assistance by a ``AccountStorageStandard``.
protocol StandardBacked: AccountService {
    associatedtype Service: AccountService
    associatedtype AccountStandard: Standard

    var accountService: Service { get }
    var standard: AccountStandard { get }

    init(service: Service, standard: AccountStandard)

    func isBacking(service accountService: any AccountService) -> Bool
}


extension StandardBacked {
    var backedId: String {
        if let nestedBacked = accountService as? any StandardBacked {
            return nestedBacked.backedId
        }

        return accountService.id
    }


    func isBacking(service: any AccountService) -> Bool {
        if let nestedBacked = self.accountService as? any StandardBacked {
            return nestedBacked.isBacking(service: service)
        }
        return self.accountService.objId == service.objId
    }
}


extension StandardBacked {
    func signUp(signupDetails: SignupDetails) async throws {
        try await accountService.signUp(signupDetails: signupDetails)
    }

    func logout() async throws {
        try await accountService.logout()
    }

    func delete() async throws {
        try await accountService.delete()
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        try await accountService.updateAccountDetails(modifications)
    }
}


extension AccountService {
    func backedBy(standard: any AccountStorageStandard) -> any AccountService {
        standard.backedService(with: self)
    }

    func backedBy(standard: any AccountNotifyStandard) -> any AccountService {
        standard.backedService(with: self)
    }
}


extension AccountStorageStandard {
    fileprivate nonisolated func backedService<Service: AccountService>(with service: Service) -> any AccountService {
        StorageStandardBackedAccountService(service: service, standard: self)
    }
}


extension AccountNotifyStandard {
    fileprivate nonisolated func backedService<Service: AccountService>(with service: Service) -> any AccountService {
        NotifyStandardBackedAccountService(service: service, standard: self)
    }
}
