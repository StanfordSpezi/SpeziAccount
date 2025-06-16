//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PhoneNumberKit
import Spezi
import SpeziAccount
import SpeziAccountPhoneNumbers
import SwiftUI


// mock implementation of the AccountStorageConstraint
actor TestStandard: AccountNotifyConstraint, PhoneVerificationConstraint, EnvironmentAccessible {
    @MainActor
    @Observable
    final class Storage {
        var deleteNotified = false
        var suppliedInitialDetails = false
        nonisolated init() {}
    }
    
    struct VerificationCodeError: Error {}
    struct AccountDetailsError: Error {}

    private let storage = Storage()
    private nonisolated let features: Features

    @Dependency(Account.self)
    private var account: Account?
    
    @Application(\.logger)
    @MainActor private var logger

    @Dependency(InMemoryAccountStorageProvider.self)
    @MainActor private var storageProvider: InMemoryAccountStorageProvider?

    @MainActor var deleteNotified: Bool {
        storage.deleteNotified
    }

    @MainActor var suppliedInitialDetails: Bool {
        storage.suppliedInitialDetails
    }

    @MainActor var hasReportedInformation: Bool {
        storage.deleteNotified || storage.suppliedInitialDetails
    }

    init(features: Features) {
        self.features = features
    }


    @MainActor
    func respondToEvent(_ event: SpeziAccount.AccountNotifications.Event) async {
        switch event {
        case .deletingAccount:
            storage.deleteNotified = true
            storage.suppliedInitialDetails = false
        case let .associatedAccount(details):
            if features.configurationType == .keysWithOptions {
                guard let storageProvider else {
                    logger.error("The account storage provider was never injected!")
                    break
                }
                var modifications = AccountDetails()
                modifications.displayOnlyOption = "This is displayed."
                do {
                    try await storageProvider.simulateRemoteUpdate(for: details.accountId, AccountModifications(modifiedDetails: modifications))
                    storage.suppliedInitialDetails = true
                } catch {
                    logger.error("Failed to updated initial account details: \(error)")
                }
            }
        case .disassociatingAccount:
            storage.suppliedInitialDetails = false
        default:
            break
        }
    }
    
    @MainActor
    func startVerification(_ number: PhoneNumber) async throws {
        // noop
    }
    
    @MainActor
    func completeVerification(_ number: PhoneNumber, _ code: String) async throws {
        guard let storageProvider else {
            logger.error("The account storage provider was never injected!")
            return
        }
        
        guard code == "012345" else {
            throw VerificationCodeError()
        }
        
        guard let accountId = await account?.details?.accountId else {
            throw AccountDetailsError()
        }
        
        let details = await storageProvider.load(accountId, [])
        var currentPhoneNumbers = details?.phoneNumbers ?? []
        currentPhoneNumbers.append(number)
        var modifications = AccountDetails()
        modifications.phoneNumbers = currentPhoneNumbers
        do {
            try await Task.sleep(for: .seconds(1)) // simulate network delay
            try await storageProvider.simulateRemoteUpdate(for: accountId, AccountModifications(modifiedDetails: modifications))
        } catch {
            logger.error("Failed to update account details: \(error)")
        }
    }
    
    @MainActor
    func delete(_ number: PhoneNumber) async throws {
        guard let storageProvider else {
            logger.error("The account storage provider was never injected!")
            return
        }
        guard let accountId = await account?.details?.accountId else {
            throw AccountDetailsError()
        }
        try await Task.sleep(for: .seconds(1)) // simulate network delay
        let details = await storageProvider.load(accountId, [])
        var currentPhoneNumbers = details?.phoneNumbers ?? []
        currentPhoneNumbers.removeAll { $0 == number }
        var modifications = AccountDetails()
        modifications.phoneNumbers = currentPhoneNumbers
        do {
            try await storageProvider.simulateRemoteUpdate(for: accountId, AccountModifications(modifiedDetails: modifications))
        } catch {
            logger.error("Failed to delete phone number: \(error)")
        }
    }
}
