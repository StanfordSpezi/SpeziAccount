//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A container that bundles added or modified ``AccountKey``s and removed ``AccountKey``s.
public struct AccountModifications: Sendable {
    /// The set of modified (or added) ``AccountKey``s.
    public let modifiedDetails: ModifiedAccountDetails
    /// The set of removed ``AccountKey``s.
    public let removedAccountDetails: RemovedAccountDetails

    init(modifiedDetails: ModifiedAccountDetails, removedAccountDetails: RemovedAccountDetails) {
        self.modifiedDetails = modifiedDetails
        self.removedAccountDetails = removedAccountDetails
    }
}
