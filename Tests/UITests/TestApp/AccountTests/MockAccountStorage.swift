//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount


actor MockAccountStorage: AccountStorageProvider { // TODO: move that to the main target!
    private var records: [String: AccountDetails] = [:] // TODO: simulate separate cache?

    func create(_ accountId: String, _ details: AccountDetails) async throws {
        records[accountId] = details
    }

    func load(_ accountId: String, _ keys: [any AccountKey.Type]) async throws -> AccountDetails? {
        guard let details = records[accountId] else {
            return nil
        }

        return details // TODO: use the keys?
    }

    func modify(_ accountId: String, _ modifications: AccountModifications) async throws {
        records[accountId, default: AccountDetails()]
            .add(contentsOf: modifications.modifiedDetails, merge: true)

        records[accountId, default: AccountDetails()]
            .removeAll(modifications.removedAccountKeys)
    }

    func disassociate(_ accountId: String) async {
        // TODO: local cache???
    }

    func delete(_ accountId: String) async throws {
        records.removeValue(forKey: accountId)
    }
}
