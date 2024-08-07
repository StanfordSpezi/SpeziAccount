//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation

public struct AccountDetailsFlags: OptionSet, Sendable { // TODO: maybe that should stay private/internal!
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}


extension AccountDetailsFlags {
    public static let isNewUser = AccountDetailsFlags(rawValue: 1 << 0)
    public static let isAnonymousUser = AccountDetailsFlags(rawValue: 1 << 1)
    public static let isVerified = AccountDetailsFlags(rawValue: 1 << 2)
    public static let isIncomplete = AccountDetailsFlags(rawValue: 1 << 3)

    // TODO: how to encode "signup provider not capable to retrieve all signup details"
}


extension AccountDetails {
    private struct IsNewUserKey: KnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = Bool
    }

    /// Determine if the user was freshly created.
    ///
    /// If this flag is set to `true`, the ``AccountSetup`` view will render a additional information sheet not only for
    /// ``AccountKeyRequirement/required``, but also for ``AccountKeyRequirement/collected`` account values.
    /// This is primarily helpful for identity providers. You might not want to set this flag
    /// if you using the builtin ``SignupForm``!
    public var isNewUser: Bool { // TODO: update these docs should the behavior change?
        get {
            self[IsNewUserKey.self] ?? false
        }
        set {
            self[IsNewUserKey.self] = newValue
        }
    }
}
