//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountKey`` for a list of bundled keys.
public struct AccountDetails {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise

    public private(set) var storage: AccountStorage


    public init() {
        self.init(from: AccountStorage())
    }


    public init(from storage: AccountStorage) {
        self.storage = storage
    }

    mutating func patchAccountServiceConfiguration(_ configuration: AccountServiceConfiguration) {
        storage[AccountServiceConfigurationDetailsKey.self] = configuration
    }

    mutating func patchIsNewUser(_ isNewUser: Bool) {
        storage[IsNewUserKey.self] = isNewUser
    }
}


extension AccountDetails: AccountValues, Sendable {}
