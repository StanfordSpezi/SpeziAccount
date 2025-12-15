//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


/// Manage Account events and notifications.
///
/// This module implements a notification system for Account-related events.
///
/// ## Topics
///
/// ### Subscribing to events
/// - ``events``
/// - ``Event``
///
/// ### Reporting events
/// Report events when implementing an `AccountService`.
/// - ``reportEvent(_:)``
public final class AccountNotifications {
    /// Describes an Account event.
    public enum Event {
        /// A new account was associated due to a login or signup operation.
        case didAssociate(_ details: AccountDetails)
        /// The details of the currently associated Account changed.
        case detailsChanged(_ previous: AccountDetails, _ new: AccountDetails)
        /// The current account is about to be logged out.
        case willLogOut(_ details: AccountDetails)
        /// The account with the given details is being disassociated (e.g., because it was logged out or deleted).
        case didDisassociate(_ details: AccountDetails)
        /// The currently associated user account is about to be deleted.
        ///
        /// This event signals that the user requested to have their account deleted and the user's data is about to be deleted.
        ///
        /// - Note: Make sure to report this event before the account is deleted. Deletion might be forwarded to an external ``AccountStorageProvider`` which
        ///     might report an error if it fails to fully delete the associated user data.
        case willDelete(_ accountId: String)
        
        @available(*, unavailable, renamed: "willDelete")
        public static func deletingAccount(_ accountId: String) -> Self {
            .willDelete(accountId)
        }
        
        @available(*, unavailable, renamed: "didAssociate")
        public static func associatedAccount(_ details: AccountDetails) -> Self {
            .didAssociate(details)
        }
        
        @available(*, unavailable, renamed: "didDisassociate")
        public static func disassociatingAccount(_ details: AccountDetails) -> Self {
            .didDisassociate(details)
        }
    }

    @StandardActor private var standard: any Standard

    @Dependency(ExternalAccountStorage.self)
    private var storage

    private var notifyStandard: (any AccountNotifyConstraint)? {
        standard as? any AccountNotifyConstraint
    }


    private var subscriptions: [UUID: AsyncStream<Event>.Continuation] = [:]
    private let lock = NSLock()


    /// Subscribe to event notifications.
    ///
    /// Use the async stream to await all future events.
    public var events: AsyncStream<Event> {
        newSubscription()
    }


    /// Initialize the notifications subsystem.
    public init() {}


    /// Report an event to the account subsystem.
    ///
    /// This method is used by an ``AccountService`` to report an event.
    /// - Note: The ``Event/deletingAccount(_:)`` is the only event that an ``AccountService`` has to manually report to the Account module.
    /// - Parameter event: The event that occurred.
    @MainActor
    public func reportEvent(_ event: Event) async throws {
        await notifyStandard?.respondToEvent(event)

        switch event {
        case let .willDelete(accountId):
            try await storage.willDeleteAccount(for: accountId)
        case let .didDisassociate(details):
            await storage.userDidDisassociate(for: details.accountId)
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


extension AccountNotifications.Event: Sendable {}


extension AccountNotifications: Module, DefaultInitializable, EnvironmentAccessible, @unchecked Sendable {}
