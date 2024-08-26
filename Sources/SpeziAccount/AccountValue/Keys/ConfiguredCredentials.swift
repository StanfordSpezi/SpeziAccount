//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


extension AccountDetails {
    fileprivate struct ConfiguredCredentials: DefaultProvidingKnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = [any AccountKey.Type]

        static let defaultValue: Value = []
    }

    /// The list of credentials that are configured for the user account.
    public var configuredCredentials: [any AccountKey.Type] {
        get {
            self[ConfiguredCredentials.self]
        }
        set {
            self[ConfiguredCredentials.self] = newValue
        }
    }
}
