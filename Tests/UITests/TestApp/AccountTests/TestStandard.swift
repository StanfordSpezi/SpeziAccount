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


// mock implementation of the AccountStorageStandard
actor TestStandard: AccountStorageStandard, AccountNotifyStandard, EnvironmentAccessible {
    @MainActor @Published var deleteNotified = false

    var records: [AdditionalRecordId: PartialAccountDetails.Builder] = [:]

    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        print("Received created!")
        records[identifier] = PartialAccountDetails.Builder(from: details)
    }

    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        let details = records[identifier, default: .init()]

        // A real-world implementation would need the keys to construct the account details from e.g. database-supplied values

        return details.build()
    }

    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        let builder = records[identifier, default: .init()]
            .merging(modifications.modifiedDetails, allowOverwrite: true)
            .remove(all: modifications.removedAccountDetails.keys)
        records[identifier] = builder // we have a class type, the `default:` is not getting stored using _modify
    }

    func clear(_ identifier: AdditionalRecordId) {
        // we don't have a local cache in that sense
    }

    func delete(_ identifier: AdditionalRecordId) async throws {
        records[identifier] = nil
    }

    @MainActor
    func deletedAccount() async {
        deleteNotified = true
    }
}
