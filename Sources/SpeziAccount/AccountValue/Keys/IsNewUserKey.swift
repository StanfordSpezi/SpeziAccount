//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


extension AccountDetails {
    private struct IsNewUserKey: KnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = Bool
    }

    /// Determine if the user was freshly created.
    public var isNewUser: Bool {
        get {
            self[IsNewUserKey.self] ?? false
        }
        set {
            self[IsNewUserKey.self] = newValue
        }
    }
}
