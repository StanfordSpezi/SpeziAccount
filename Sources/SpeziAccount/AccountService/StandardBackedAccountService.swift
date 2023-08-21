//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

/// Internal marker protocol to determine what ``AccountService`` require assistance by a ``AccountStorageStandard``.
protocol StandardBacked {
    associatedtype Standard: AccountStorageStandard
    var standard: Standard { get }
}


public actor StandardBackedAccountService<Service: AccountService, Standard: AccountStorageStandard>: AccountService, StandardBacked {
    @AccountReference private var account

    let accountService: Service
    let standard: Standard
    let serviceSupportedKeys: AccountKeyCollection

    public nonisolated var configuration: AccountServiceConfiguration {
        accountService.configuration
    }

    public nonisolated var viewStyle: Service.ViewStyle {
        accountService.viewStyle
    }


    private var currentUserId: String? {
        get async {
            await account.details?.userId
        }
    }


    init(service accountService: Service, standard: Standard) {
        guard case let .exactly(keys) = accountService.configuration.supportedAccountKeys else {
            preconditionFailure("Cannot initialize a \(Self.self) where the underlying service \(Service.self) does support all account keys!")
        }

        self.accountService = accountService
        self.standard = standard
        self.serviceSupportedKeys = keys
    }


    public func signUp(signupDetails: SignupDetails) async throws {
        let details = splitDetails(from: signupDetails)

        let recordId = AdditionalRecordId(serviceId: accountService.id, userId: signupDetails.userId)

        // call standard first, such that it will happen before any `supplyAccountDetails` calls made by the Account Service
        try await standard.create(recordId, details.standard)

        try await accountService.signUp(signupDetails: details.service)
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        guard let userId = await currentUserId else {
            return
        }

        let modifiedDetails = splitDetails(from: modifications.modifiedDetails)
        let removedDetails = splitDetails(from: modifications.removedAccountDetails)

        let serviceModifications = AccountModifications(
            modifiedDetails: modifiedDetails.service,
            removedAccountDetails: removedDetails.service
        )

        let standardModifications = AccountModifications(
            modifiedDetails: modifiedDetails.standard,
            removedAccountDetails: removedDetails.standard
        )

        let recordId = AdditionalRecordId(serviceId: accountService.id, userId: userId)

        // first call the standard, such that it will happen before any `supplyAccountDetails` calls made by the Account Service
        try await standard.modify(recordId, standardModifications)

        try await accountService.updateAccountDetails(serviceModifications)
    }

    public func logout() async throws {
        try await accountService.logout()
    }

    public func delete() async throws {
        guard let userId = await currentUserId else {
            return
        }

        try await standard.delete(AdditionalRecordId(serviceId: accountService.id, userId: userId))
        try await accountService.delete()
    }

    private func splitDetails<Container: AccountValues>(
        from details: Container
    ) -> (service: Container, standard: Container) {
        let serviceBuilder = AccountValuesBuilder<Container>()
        let standardBuilder = AccountValuesBuilder<Container>(from: details)


        for element in serviceSupportedKeys {
            // remove all service supported keys from the standard builder (which is a copy of `details` currently)
            standardBuilder.remove(element.key)
        }

        // copy all values from `details` of the service supported keys into the service builder
        serviceBuilder.merging(with: serviceSupportedKeys, from: details)

        return (serviceBuilder.build(), standardBuilder.build())
    }
}


extension StandardBackedAccountService: EmbeddableAccountService where Service: EmbeddableAccountService {}


extension StandardBackedAccountService: UserIdPasswordAccountService where Service: UserIdPasswordAccountService {
    public func login(userId: String, password: String) async throws {
        // the standard is queried once the account service calls `supplyAccountDetails`
        try await accountService.login(userId: userId, password: password)
    }

    public func resetPassword(userId: String) async throws {
        try await accountService.resetPassword(userId: userId)
    }
}


extension AccountService {
    func backedBy(standard: any AccountStorageStandard) -> any AccountService {
        standard.backedService(with: self)
    }
}


extension AccountStorageStandard {
    fileprivate nonisolated func backedService<Service: AccountService>(with service: Service) -> any AccountService {
        StandardBackedAccountService(service: service, standard: self)
    }
}
