//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import SpeziAccount
import SpeziTesting
import Testing

@Suite("AccountDetails Cache Tests", .serialized)
struct AccountDetailsCacheTests {
    private static let id = UUID(uuidString: "b730ebce-e153-44fc-a547-d47ac9c9d190")! // swiftlint:disable:this force_unwrapping

    @MainActor
    @Test
    func testCache() async {
        let cache = AccountDetailsCache(settings: .unencrypted())
        withDependencyResolution {
            cache
        }

        let details: AccountDetails = .mock(id: Self.id)
        await cache.clearEntry(for: details.accountId)

        let nilEntry = await cache.loadEntry(for: details.accountId, details.keys)
        #expect(nilEntry == nil)

        await cache.communicateRemoteChanges(for: details.accountId, details)

        let entry = await cache.loadEntry(for: details.accountId, details.keys)
        #expect(entry != nil)
        if let entry {
            assertDetails(entry, details)
        }


        await cache.purgeMemoryCache(for: details.accountId)
        let entryFromDisk = await cache.loadEntry(for: details.accountId, details.keys)
        #expect(entryFromDisk != nil)
        if let entryFromDisk {
            assertDetails(entryFromDisk, details)
        }

        await cache.clearEntry(for: details.accountId)
        let nilEntry2 = await cache.loadEntry(for: details.accountId, details.keys)
        #expect(nilEntry2 == nil)
    }

    @MainActor
    @Test
    func testApplyModifications() async {
        let cache = AccountDetailsCache(settings: .unencrypted())
        withDependencyResolution {
            cache
        }


        var details: AccountDetails = .mock(id: Self.id)
        let keys = details.keys
        await cache.clearEntry(for: details.accountId)

        await cache.communicateRemoteChanges(for: details.accountId, details)

        var modified = AccountDetails()
        var removed = AccountDetails()
        modified.userId = "lelandstanford2@stanford.edu"
        removed.password = details.password

        details.userId = modified.userId
        details.password = nil
        let modifications = try! AccountModifications(modifiedDetails: modified, removedAccountDetails: removed) // swiftlint:disable:this force_try

        await cache.communicateModifications(for: details.accountId, modifications)


        let localEntry = await cache.loadEntry(for: details.accountId, keys)
        #expect(localEntry != nil)
        if let localEntry {
            assertDetails(localEntry, details)
        }

        await cache.purgeMemoryCache(for: details.accountId)
        let diskEntry = await cache.loadEntry(for: details.accountId, keys)
        #expect(diskEntry != nil)
        if let diskEntry {
            assertDetails(diskEntry, details)
        }

        await cache.clearEntry(for: details.accountId)
    }
}
