//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


struct AccountDetailsFlags: OptionSet, Sendable {
    let rawValue: UInt16

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}


extension AccountDetailsFlags {
    static let isNewUser = AccountDetailsFlags(rawValue: 1 << 0)
    static let isAnonymousUser = AccountDetailsFlags(rawValue: 1 << 1)
    static let isVerified = AccountDetailsFlags(rawValue: 1 << 2)
    static let isIncomplete = AccountDetailsFlags(rawValue: 1 << 3)
}


extension AccountDetails {
    fileprivate struct AccountDetailsFlagsKey: DefaultProvidingKnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = AccountDetailsFlags

        static let defaultValue: AccountDetailsFlags = []
    }

    var flags: AccountDetailsFlags {
        get {
            self[AccountDetailsFlagsKey.self]
        }
        set {
            self[AccountDetailsFlagsKey.self] = newValue
        }
    }
}


extension AccountDetails {
    /// Determine if the user was freshly created.
    public var isNewUser: Bool {
        get {
            flags.contains(.isNewUser)
        }
        set {
            if newValue {
                flags.insert(.isNewUser)
            } else {
                flags.remove(.isNewUser)
            }
        }
    }
}


extension AccountDetails {
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
            flags.contains(.isAnonymousUser)
        }
        set {
            if newValue {
                flags.insert(.isAnonymousUser)
            } else {
                flags.remove(.isAnonymousUser)
            }
        }
    }
}


extension AccountDetails {
    /// Determine if the user's identity was verified.
    ///
    /// Identity verification is typically done by verifying the existence and ownership of the e-mail address the user signed up with.
    /// How verification is determined, if at all, is up to the ``AccountService`` to decide.
    public var isVerified: Bool {
        get {
            flags.contains(.isVerified)
        }
        set {
            if newValue {
                flags.insert(.isVerified)
            } else {
                flags.remove(.isVerified)
            }
        }
    }
}


extension AccountDetails {
    /// The account details are incomplete and additional details are currently getting loaded.
    ///
    /// The account details are currently considered incomplete. A ``AccountStorageProvider`` is currently loading additional,
    /// externally stored account details. Until then the profile is considered incomplete.
    public var isIncomplete: Bool {
        get {
            flags.contains(.isIncomplete)
        }
        set {
            if newValue {
                flags.insert(.isIncomplete)
            } else {
                flags.remove(.isIncomplete)
            }
        }
    }
}
