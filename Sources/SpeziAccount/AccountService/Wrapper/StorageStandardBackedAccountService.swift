//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// An ``AccountService`` implementation for account services with ``SupportedAccountKeys/exactly(_:)`` configuration
/// to forward unsupported account values to a ``AccountStorageConstraint`` implementation.
actor StorageStandardBackedAccountService<Service: AccountService, Standard: AccountStorageConstraint>: AccountService, _StandardBacked {
    @AccountReference private var account

    let accountService: Service
    let standard: Standard
    let serviceSupportedKeys: AccountKeyCollection

    private var pendingSignupDetails: SignupDetails?

    nonisolated var configuration: AccountServiceConfiguration {
        accountService.configuration
    }

    nonisolated var viewStyle: Service.ViewStyle {
        accountService.viewStyle
    }


    private var currentAccountId: String? {
        get async {
            let account = account
            return await account.details?.accountId
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

    func signUp(signupDetails: SignupDetails) async throws {
        let details = splitDetails(from: signupDetails)

        // save the details until the accountId is available. This will be in preUserDetailsSupply
        self.pendingSignupDetails = details.standard

        try await accountService.signUp(signupDetails: details.service)
    }

    func preUserDetailsSupply(recordId: AdditionalRecordId) async throws {
        if let pendingSignupDetails {
            try await standard.create(recordId, pendingSignupDetails)
            self.pendingSignupDetails = nil
        }
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        guard let accountId = await currentAccountId else {
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

        let recordId = AdditionalRecordId(serviceId: accountService.id, accountId: accountId)

        // first call the standard, such that it will happen before any `supplyAccountDetails` calls made by the Account Service
        try await standard.modify(recordId, standardModifications)

        try await accountService.updateAccountDetails(serviceModifications)
    }

    func delete() async throws {
        guard let accountId = await currentAccountId else {
            return
        }

        try await standard.delete(AdditionalRecordId(serviceId: accountService.id, accountId: accountId))
        try await accountService.delete()
    }

    private func splitDetails<Values: AccountValues>(
        from details: Values
    ) -> (service: Values, standard: Values) {
        let serviceBuilder = AccountValuesBuilder<Values>()
        let standardBuilder = AccountValuesBuilder<Values>(from: details)


        for element in serviceSupportedKeys {
            // remove all service supported keys from the standard builder (which is a copy of `details` currently)
            standardBuilder.remove(element.key)
        }

        // copy all values from `details` of the service supported keys into the service builder
        serviceBuilder.merging(with: serviceSupportedKeys, from: details)

        return (serviceBuilder.build(), standardBuilder.build())
    }
}


extension StorageStandardBackedAccountService: EmbeddableAccountService where Service: EmbeddableAccountService {}

extension StorageStandardBackedAccountService: UserIdPasswordAccountService where Service: UserIdPasswordAccountService {}

extension StorageStandardBackedAccountService: IdentityProvider where Service: IdentityProvider {}
