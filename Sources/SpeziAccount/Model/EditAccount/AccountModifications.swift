//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// TDOO use
public struct AccountModifications: Sendable {
    public let modifiedDetails: ModifiedAccountDetails
    public let removedAccountDetails: RemovedAccountDetails

    init(modifiedDetails: ModifiedAccountDetails, removedAccountDetails: RemovedAccountDetails) {
        self.modifiedDetails = modifiedDetails
        self.removedAccountDetails = removedAccountDetails
    }
}
