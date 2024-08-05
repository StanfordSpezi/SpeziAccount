//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


extension AccountDetails {
    private struct IsAnonymousUser: KnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = Bool
    }

    /// Determine if the user was anonymously signed up.
    ///
    /// Anonymous accounts do not have any credentials linked to their account. They are typically used to have an ``accountId`` to link
    /// user data without requiring the user to explicitly create an account and decide for credentials.
    ///
    /// The ``AccountSetup`` view will still show setup options if an anonymous user account is associated.
    /// An ``AccountService`` that supports creating anonymous details, must support automatically linking a setup operation to the current
    /// anonymous user account.
    ///
    /// The ``AccountOverview`` will show an anonymous user account and allows to edit details of an anonymous user.
    /// An `AccountService` must support editing user details of an anonymous user.
    public var isAnonymous: Bool {
        get {
            self[IsAnonymousUser.self] ?? false
        }
        set {
            self[IsAnonymousUser.self] = newValue
        }
    }
}
