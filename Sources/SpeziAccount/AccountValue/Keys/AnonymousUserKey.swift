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
    public var isAnonymous: Bool {
        get {
            self[IsAnonymousUser.self] ?? false
        }
        set {
            self[IsAnonymousUser.self] = newValue
        }
    }
}
