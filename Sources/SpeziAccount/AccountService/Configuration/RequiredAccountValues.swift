//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct RequiredAccountValues: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static let defaultValue = RequiredAccountValues(ofKeys: [])

    fileprivate let keys: AccountKeyCollection

    public init(ofKeys keys: AccountKeyCollection) {
        self.keys = keys
    }

    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountValueKey.Type]) {
        self.init(ofKeys: AccountKeyCollection(keys))
    }
}


extension AccountServiceConfiguration {
    /// Access the required account values of an ``AccountService``.
    public var requiredAccountValues: AccountKeyCollection {
        storage[RequiredAccountValues.self].keys
    }
}
