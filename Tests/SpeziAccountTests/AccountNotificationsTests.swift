//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@testable import SpeziAccount
import Testing
import XCTSpezi

private final class TestProvider: AccountStorageProvider {
    private let onDisassociate: Testing.Confirmation
    private let onDelete: Testing.Confirmation

    init(onDisassociate: Testing.Confirmation, onDelete: Testing.Confirmation) {
        self.onDisassociate = onDisassociate
        self.onDelete = onDelete
    }
    
    func store(_ accountId: String, _ modifications: SpeziAccount.AccountModifications) async throws {
        Issue.record("\(#function) not implemented")
    }

    func load(_ accountId: String, _ keys: [any SpeziAccount.AccountKey.Type]) async -> SpeziAccount.AccountDetails? {
        Issue.record("\(#function) not implemented")
        return nil
    }

    func disassociate(_ accountId: String) async {
        onDisassociate()
    }

    func delete(_ accountId: String) async throws {
        onDelete()
    }
}


private final actor TestStandard: Standard, AccountNotifyConstraint {
    @MainActor private(set) var trackedEvents: [AccountNotifications.Event] = []

    @MainActor
    func respondToEvent(_ event: AccountNotifications.Event) async {
        trackedEvents.append(event)
    }
}

struct AccountNotificationsTests {
    @MainActor
    @Test("AccountNotifications Test", .timeLimit(.minutes(1)))
    func testAccountNotifications() async throws {
        try await confirmation("disassociated") { confirmDisassociate in // swiftlint:disable:this closure_body_length
            try await confirmation("delete") { confirmDelete in // swiftlint:disable:this closure_body_length
                let notifications = AccountNotifications()
                let standard = TestStandard()
                let provider = TestProvider(
                    onDisassociate: confirmDisassociate,
                    onDelete: confirmDelete
                )
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
                
                func assertEvents(
                    _ event0: AccountNotifications.Event?,
                    _ event1: AccountNotifications.Event?,
                    _ event2: AccountNotifications.Event?
                ) {
                    if case let .deletingAccount(id) = element0 {
                        #expect(id == "account1")
                    } else {
                        Issue.record("Unexpected first element \(String(describing: element0))")
                    }
                    
                    if case let .associatedAccount(associated) = element1 {
                        assertDetails(associated, details)
                    } else {
                        Issue.record("Unexpected second element \(String(describing: element1))")
                    }
                    
                    if case let .disassociatingAccount(disassociated) = element2 {
                        assertDetails(disassociated, details)
                    } else {
                        Issue.record("Unexpected third element \(String(describing: element2))")
                    }
                }
                
                assertEvents(element0, element1, element2)
                
                #expect(standard.trackedEvents.count == 3)
                
                let event0 = standard.trackedEvents[0]
                let event1 = standard.trackedEvents[1]
                let event2 = standard.trackedEvents[2]
                assertEvents(event0, event1, event2)
            }
        }
    }
}
