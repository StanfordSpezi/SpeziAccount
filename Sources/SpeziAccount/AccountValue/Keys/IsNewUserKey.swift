//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


private struct IsNewUserKey: KnowledgeSource {
    typealias Anchor = AccountAnchor
    typealias Value = Bool
}

extension AccountDetails {
    public var isNewUser: Bool {
        get {
            storage[IsNewUserKey.self] ?? false
        }
        set {
            storage[IsNewUserKey.self] = newValue
        }
    }
}
