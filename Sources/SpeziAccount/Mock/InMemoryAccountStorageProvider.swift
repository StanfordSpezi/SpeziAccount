//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// In Memory Storage Provider useful for testing and Previews.
///
/// This ``AccountStorageProvider`` is implemented using an in-memory stored dictionary of ``AccountDetails``. It serves as a minimal
/// example on how to implement a external storage provider and can be easily integrated in SwiftUI previews and UI tests.
public actor InMemoryAccountStorageProvider: AccountStorageProvider {
    private var records: [String: AccountDetails] = [:]
    private var cache: [String: AccountDetails] = [:] // simulates an in-memory cache

    @Dependency(ExternalAccountStorage.self)
    private var storage

    public init() {}

    /// Used in testing to simulate a remote update and inject stored values into the storage provider
    ///
    /// This will case the account service to be notified about updated details.
    /// - Parameters:
    ///   - accountId: The account id.
    ///   - modifications: The modifications to apply.
    public func simulateRemoteUpdate(for accountId: String, _ modifications: AccountModifications) {
        self.store(accountId, modifications)

        guard let details = records[accountId] else {
            fatalError("Inconsistent state!")
        }

        storage.notifyAboutUpdatedDetails(for: accountId, details)
    }

    public func load(_ accountId: String, _ keys: [any AccountKey.Type]) -> AccountDetails? {
        guard let details = cache[accountId] else {
            guard records[accountId] != nil else {
                return AccountDetails() // no data present
            }

            // simulate loading from external storage
            Task {
                try await Task.sleep(for: .seconds(1))

                let details = records[accountId] ?? AccountDetails()

                cache[accountId] = details
                storage.notifyAboutUpdatedDetails(for: accountId, details)
            }
            return nil
        }

        return details
    }

    public func store(_ accountId: String, _ modifications: AccountModifications) {
        records[accountId, default: AccountDetails()]
            .add(contentsOf: modifications.modifiedDetails, merge: true)

        records[accountId, default: AccountDetails()]
            .removeAll(modifications.removedAccountKeys)

        cache[accountId] = records[accountId] // update cache
    }

    public func disassociate(_ accountId: String) {
        cache.removeValue(forKey: accountId)
    }

    public func delete(_ accountId: String) throws {
        self.disassociate(accountId)
        records.removeValue(forKey: accountId)
    }
}
