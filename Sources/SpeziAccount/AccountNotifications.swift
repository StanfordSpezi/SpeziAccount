//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


public final class AccountNotifications {
    public struct Event {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    @StandardActor private var standard: any Standard

    @Dependency private var storage: ExternalAccountStorage

    private var notifyStandard: (any AccountNotifyConstraint)? {
        standard as? any AccountNotifyConstraint
    }


    private var subscriptions: [UUID: AsyncStream<Event>.Continuation] = [:]
    private let lock = NSLock()


    public var events: AsyncStream<Event> {
        newSubscription()
    }

    
    public init() {}


    // TODO: can we somehow enforce that the account services reports the deletingAccount event?

    @MainActor
    public func reportEvent(_ event: Event, for accountId: String) async throws {
        try await notifyStandard?.respondToEvent(event)

        switch event {
        case .deletingAccount:
            try await storage.willDeleteAccount(for: accountId)
        case .disassociatingAccount:
            await storage.userWillDisassociate(for: accountId)
        default:
            break
        }

        lock.withLock {
            for subscription in subscriptions.values {
                subscription.yield(event)
            }
        }
    }


    private func newSubscription() -> AsyncStream<Event> {
        AsyncStream { continuation in
            let id = UUID()
            lock.withLock {
                subscriptions[id] = continuation
            }

            continuation.onTermination = { [weak self, id] _ in
                guard let self else {
                    return
                }
                lock.withLock {
                    _ = self.subscriptions.removeValue(forKey: id)
                }
            }
        }
    }
}


extension AccountNotifications.Event {
    /// The currently associated user account is about to be deleted.
    ///
    /// This event signals that the user requested to have their account deleted and the user's data is about to be deleted.
    /// This event is reported before the ``AccountService`` deletes any user data and therefore the user ``Account/details`` are still accessible.
    public static let deletingAccount: Self = "deletingAccount"

    public static let associatedAccount: Self = "associatedAccount"

    public static let detailsChanged: Self = "detailsChanged"

    public static let disassociatingAccount: Self = "disassociatedAccount"
}


extension AccountNotifications.Event: Sendable, Hashable, RawRepresentable {}


extension AccountNotifications.Event: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}


extension AccountNotifications: Module, DefaultInitializable, EnvironmentAccessible, @unchecked Sendable {}
