//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct RequiredAccountKeys: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static let defaultValue = RequiredAccountKeys(ofKeys: .init()) // TODO UserId + Password is always required for the UserId account service

    fileprivate let keys: AccountKeyCollection

    public init(ofKeys keys: AccountKeyCollection) {
        self.keys = keys
    }

    public init(@AccountKeyCollectionBuilder _ keys: () -> [any AccountKeyWithDescription]) {
        self.init(ofKeys: AccountKeyCollection(keys))
    }
}


extension AccountServiceConfiguration {
    /// Access the required account values of an ``AccountService``.
    public var requiredAccountKeys: AccountKeyCollection {
        storage[RequiredAccountKeys.self].keys
    }
}
