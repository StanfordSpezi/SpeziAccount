//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
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

    // TODO: snapshot test some of the display views + preferred setup views? + AccountHeader!

    @MainActor
    func testApplyModifications() async {
        continueAfterFailure = true // ensure entries are cleared at the end

        let cache = AccountDetailsCache(settings: .unencrypted())
        withDependencyResolution {
            cache
        }


        var details: AccountDetails = .mock(id: Self.id)
        let keys = details.keys // TODO: decoding fails with more keys than expected where presented? => is that a problem, generally yes right?
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


        let localEntry = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNotNil(localEntry)
        if let localEntry {
            XCTAssertDetails(localEntry, details)
        }

        await cache.purgeMemoryCache(for: details.accountId)
        let diskEntry = await cache.loadEntry(for: details.accountId, details.keys)
        XCTAssertNotNil(diskEntry)
        if let diskEntry {
            XCTAssertDetails(diskEntry, details)
        }

        await cache.clearEntry(for: details.accountId)
    }

    @MainActor
    func testAccountNotifications() async throws { // TODO: move
        let notifications = AccountNotifications()
        withDependencyResolution {
            notifications
            ExternalAccountStorage(nil) // TODO: test that will associasted and will delete are forwarded to storage provider?
        }

        // TODO: test call to standard?

        let stream = notifications.events

        let details: AccountDetails = .mock()

        try await notifications.reportEvent(.deletingAccount("account1"))
        try await notifications.reportEvent(.associatedAccount(details))

        var iterator = stream.makeAsyncIterator()

        let element0 = await iterator.next()
        let element1 = await iterator.next()

        if case let .deletingAccount(id) = element0 {
            XCTAssertEqual(id, "account1")
        } else {
            XCTFail("Unexpected first element \(String(describing: element0))")
        }

        if case let .associatedAccount(associated) = element1 {
            XCTAssertDetails(associated, details)
        } else {
            XCTFail("Unexpected second element \(String(describing: element1))")
        }
    }
}
