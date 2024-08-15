//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


extension AccountDetails {
    private struct DecodingErrors: KnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = [(any AccountKey.Type, Error)]
    }

    /// Errors occurred while decoding `AccountDetails`
    public var decodingErrors: [(any AccountKey.Type, Error)]? { // swiftlint:disable:this discouraged_optional_collection
        get {
            self[DecodingErrors.self]
        }
        set {
            self[DecodingErrors.self] = newValue
        }
    }
}
