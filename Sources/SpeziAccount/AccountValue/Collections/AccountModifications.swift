//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A container that bundles added or modified ``AccountKey``s and removed ``AccountKey``s.
public struct AccountModifications {
    /// The set of modified (or added) ``AccountKey``s.
    public let modifiedDetails: AccountDetails
    /// The set of removed ``AccountKey``s.
    public let removedAccountDetails: AccountDetails

    /// The list of removed account keys.
    ///
    /// This property is derived from ``removedAccountDetails`` which also provides access to the removed values.
    public var removedAccountKeys: [any AccountKey.Type] {
        removedAccountDetails.keys
    }

    public init(modifiedDetails: AccountDetails, removedAccountDetails: AccountDetails = AccountDetails()) throws {
        self.modifiedDetails = modifiedDetails
        self.removedAccountDetails = removedAccountDetails

        if modifiedDetails.contains(AccountIdKey.self) || removedAccountDetails.contains(AccountIdKey.self) {
            throw AccountOperationError.accountIdChanged
        }
    }
}


extension AccountModifications: Sendable {}
