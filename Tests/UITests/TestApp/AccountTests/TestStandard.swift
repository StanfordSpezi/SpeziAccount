//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount


// mock implementation of the AccountStorageStandard
actor TestStandard: AccountStorageStandard {
    var records: [AdditionalRecordId: PartialAccountDetails.Builder] = [:]

    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        records[identifier] = PartialAccountDetails.Builder(from: details)
    }

    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        let details = records[identifier, default: .init()]

        // validation just for our test. A real-world implementation would need the keys to construct the account details
        // from e.g. database-supplied values
        for key in keys {
            precondition(details.contains(key), "Couldn't find the key \(key) in our record of stored data")
        }

        return details.build()
    }

    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        records[identifier, default: .init()]
            .merging(modifications.modifiedDetails, allowOverwrite: true)
            .remove(all: modifications.removedAccountDetails.keys)
    }

    func clear(_ identifier: AdditionalRecordId) {
        // we don't have a local cache in that sense
    }

    func delete(_ identifier: AdditionalRecordId) async throws {
        records[identifier] = nil
    }
}
