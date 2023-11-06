//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// Internal marker protocol to determine what ``AccountService`` require assistance by a ``AccountStorageStandard``.
public protocol _StandardBacked: AccountService { // swiftlint:disable:this type_name
    associatedtype Service: AccountService
    associatedtype AccountStandard: Standard

    var accountService: Service { get }
    var standard: AccountStandard { get }

    /// Retrieves the underlying account service, resolving multiple levels of nesting.
    var underlyingService: any AccountService { get }

    init(service: Service, standard: AccountStandard)

    /// ObjectIdentifier-based check if they underlying account service equals the provided one.
    func isBacking(service accountService: any AccountService) -> Bool

    func preUserDetailsSupply(recordId: AdditionalRecordId) async throws
}


extension _StandardBacked {
    /// The account service id of the underlying account service
    public var backedId: String {
        underlyingService.id
    }

    /// Recursively retrieves the innermost account service.
    public var underlyingService: any AccountService {
        if let nestedBacked = accountService as? any _StandardBacked {
            return nestedBacked.underlyingService
        }
        return accountService
    }

    /// An ObjectIdentifier-based check if they underlying account service equals the provided one.
    public func isBacking(service: any AccountService) -> Bool {
        underlyingService.objId == service.objId
    }

    /// Default implementation.
    public func preUserDetailsSupply(recordId: AdditionalRecordId) async throws {}
}


extension _StandardBacked {
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


extension _StandardBacked where Self: UserIdPasswordAccountService, Service: UserIdPasswordAccountService {
    func login(userId: String, password: String) async throws {
        try await accountService.login(userId: userId, password: password)
    }

    func resetPassword(userId: String) async throws {
        try await accountService.resetPassword(userId: userId)
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
