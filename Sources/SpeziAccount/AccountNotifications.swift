//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


public final class AccountNotifications { // TODO: environment accessible
    public enum Events {
        case deletedAccount // TODO: make it extensible?
        // TODO: other cases
    }

    @StandardActor private var standard: any Standard

    private var notifyStandard: (any AccountNotifyConstraint)? {
        standard as? any AccountNotifyConstraint
    }


    private var subscriptions: [UUID: AsyncStream<Events>.Continuation] = [:]
    private let lock = NSLock()


    public var events: AsyncStream<Events> {
        newSubscription()
    }

    
    public init() {}


    public func reportEvent(_ event: Events) async throws { // TODO: AccountService SPI?
        // TODO: should be able to be try throwing? => e.g. ensure something is cleanup before something else happens?
        switch event {
        case .deletedAccount:
            try await notifyStandard?.deletedAccount() // TODO: generalized events method?
        }

        lock.withLock {
            for subscription in subscriptions.values {
                subscription.yield(event)
            }
        }
    }


    private func newSubscription() -> AsyncStream<Events> {
        AsyncStream { continuation in
            let id = UUID()
            lock.withLock {
                subscriptions[id] = continuation
            }

            continuation.onTermination = { [weak self, id] termination in
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


extension AccountNotifications.Events: Sendable, Hashable {}


extension AccountNotifications: Module, DefaultInitializable, @unchecked Sendable {}
