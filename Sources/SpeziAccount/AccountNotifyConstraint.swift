//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A `Spezi` Standard that allows to react to certain Account-based events.
///
/// Adopt this protocol in your Standard to respond to `Account` events.
///
/// ```swift
/// import Spezi
/// import SpeziAccount
///
/// actor MyStandard: Standard, AccountNotifyConstraint {
///     init() {}
///
///     func respondToEvent(_ event: AccountNotifications.Event) async {
///         switch event {
///         case .deletingAccount(let accountId):
///             // handle deletion of associated user data
///         }
///     }
/// }
/// ```
public protocol AccountNotifyConstraint: Standard {
    /// Notifies the Standard that an event for the currently associated user occurred.
    ///
    /// For more information refer to ``AccountNotifications/Event``.
    func respondToEvent(_ event: AccountNotifications.Event) async
    
    /// Notifies the standard that the currently logged-in account is about to be logged out.
    ///
    /// - Note: This function will be folded into the ``AccountNotifications/Event`` enum in a future release.
    func willLogOut(_ details: AccountDetails) async
}


extension AccountNotifyConstraint {
    // swiftlint:disable:next missing_docs
    public func willLogOut(_ details: AccountDetails) async {}
}
