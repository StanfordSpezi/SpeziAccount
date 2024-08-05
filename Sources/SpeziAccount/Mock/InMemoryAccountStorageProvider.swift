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

    public func create(_ accountId: String, _ details: AccountDetails) throws {
        // we treat a creating the same as a modify with just the created details
        modify(accountId, try AccountModifications(modifiedDetails: details))
    }

    public func load(_ accountId: String, _ keys: [any AccountKey.Type]) -> AccountDetails? {
        guard let details = cache[accountId] else {
            guard records[accountId] != nil else {
                return nil
            }

            // simulate loading from external storage
            Task {
                try await Task.sleep(for: .seconds(1))
                guard let details = records[accountId] else {
                    return
                }
                cache[accountId] = details
                storage.notifyAboutUpdatedDetails(for: accountId, details)
            }
            return nil
        }

        return details
    }

    public func modify(_ accountId: String, _ modifications: AccountModifications) {
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
