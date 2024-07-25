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
    // TODO: if we remove the protocol AccountValues infrastructure, we can make this internal again (init as well!)
    public private(set) var storage: AccountStorage


    /// Initialize empty account details.
    public init() {
        self.init(from: AccountStorage())
    }


    public init(from storage: AccountStorage) { // TODO: why is this public?
        self.storage = storage
    }

    mutating func patchAccountServiceConfiguration(_ configuration: AccountServiceConfiguration) {
        storage[AccountServiceConfigurationDetailsKey.self] = configuration
    }

    mutating func patchIsNewUser(_ isNewUser: Bool) {
        storage[IsNewUserKey.self] = isNewUser
    }
}


extension AccountDetails: AccountValues, Sendable {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise
}
