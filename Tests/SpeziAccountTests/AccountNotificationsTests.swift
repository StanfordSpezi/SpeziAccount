//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@testable import SpeziAccount
import XCTest
import XCTSpezi


private final class TestProvider: AccountStorageProvider {
    let disassociatedExpectation: XCTestExpectation
    let deleteExpectation: XCTestExpectation

    init(disassociatedExpectation: XCTestExpectation, deleteExpectation: XCTestExpectation) {
        self.disassociatedExpectation = disassociatedExpectation
        self.deleteExpectation = deleteExpectation
    }

    func store(_ accountId: String, _ modifications: SpeziAccount.AccountModifications) async throws {
        XCTFail("\(#function) not implemented")
    }

    func load(_ accountId: String, _ keys: [any SpeziAccount.AccountKey.Type]) async -> SpeziAccount.AccountDetails? {
        XCTFail("\(#function) not implemented")
        return nil
    }

    func disassociate(_ accountId: String) async {
        disassociatedExpectation.fulfill()
    }

    func delete(_ accountId: String) async throws {
        deleteExpectation.fulfill()
    }
}


private final actor TestStandard: Standard, AccountNotifyConstraint {
    @MainActor private(set) var trackedEvents: [AccountNotifications.Event] = []

    @MainActor
    func respondToEvent(_ event: AccountNotifications.Event) async {
        trackedEvents.append(event)
    }
}


final class AccountNotificationsTests: XCTestCase {
    @MainActor
    func testAccountNotifications() async throws {
        let disassociatedExpectation = XCTestExpectation(description: "disassociated")
        let deleteExpectation = XCTestExpectation(description: "delete")

        let notifications = AccountNotifications()
        let standard = TestStandard()
        let provider = TestProvider(disassociatedExpectation: disassociatedExpectation, deleteExpectation: deleteExpectation)
        withDependencyResolution(standard: standard) {
            notifications
            ExternalAccountStorage(provider)
        }

        let stream = notifications.events

        let details: AccountDetails = .mock()

        try await notifications.reportEvent(.deletingAccount("account1"))
        try await notifications.reportEvent(.associatedAccount(details))
        try await notifications.reportEvent(.disassociatingAccount(details))

        var iterator = stream.makeAsyncIterator()

        let element0 = await iterator.next()
        let element1 = await iterator.next()
        let element2 = await iterator.next()

        func assertEvents(_ event0: AccountNotifications.Event?, _ event1: AccountNotifications.Event?, _ event2: AccountNotifications.Event?) {
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

            if case let .disassociatingAccount(disassociated) = element2 {
                XCTAssertDetails(disassociated, details)
            } else {
                XCTFail("Unexpected third element \(String(describing: element2))")
            }
        }

        assertEvents(element0, element1, element2)

        await fulfillment(of: [disassociatedExpectation, deleteExpectation], timeout: 2.0)

        XCTAssertEqual(standard.trackedEvents.count, 3)

        let event0 = standard.trackedEvents[0]
        let event1 = standard.trackedEvents[1]
        let event2 = standard.trackedEvents[2]
        assertEvents(event0, event1, event2)
    }
}
