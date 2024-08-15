//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziAccount
import XCTest
import XCTSpezi


final class AccountDetailsCacheTests: XCTestCase {
    private static let id = UUID(uuidString: "b730ebce-e153-44fc-a547-d47ac9c9d190")! // swiftlint:disable:this force_unwrapping

    @MainActor
    func testCache() async {
        continueAfterFailure = true // ensure entries are cleared at the end

        let cache = AccountDetailsCache(settings: .unencrypted())
        withDependencyResolution {
            cache
        }


        let details: AccountDetails = .mock(id: Self.id)
        await cache.clearEntry(for: details.accountId)

        let nilEntry = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNil(nilEntry)

        await cache.communicateRemoteChanges(for: details.accountId, details)

        let entry = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNotNil(entry)
        if let entry {
            XCTAssertDetails(entry, details)
        }


        await cache.purgeMemoryCache(for: details.accountId)
        let entryFromDisk = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNotNil(entryFromDisk)
        if let entryFromDisk {
            XCTAssertDetails(entryFromDisk, details)
        }

        await cache.clearEntry(for: details.accountId)
        let nilEntry2 = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNil(nilEntry2)
    }

    @MainActor
    func testApplyModifications() async {
        continueAfterFailure = true // ensure entries are cleared at the end

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
        XCTAssertNotNil(localEntry)
        if let localEntry {
            XCTAssertDetails(localEntry, details)
        }

        await cache.purgeMemoryCache(for: details.accountId)
        let diskEntry = await cache.loadEntry(for: details.accountId, keys)
        XCTAssertNotNil(diskEntry)
        if let diskEntry {
            XCTAssertDetails(diskEntry, details)
        }

        await cache.clearEntry(for: details.accountId)
    }
}
