//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SwiftUI


// mock implementation of the AccountStorageConstraint
actor TestStandard: AccountNotifyConstraint, EnvironmentAccessible {
    @MainActor
    @Observable
    final class Storage {
        var deleteNotified = false
        var suppliedInitialDetails = false
        nonisolated init() {}
    }

    private let storage = Storage()
    private nonisolated let features: Features

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
}
