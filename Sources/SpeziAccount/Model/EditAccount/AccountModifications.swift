//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// TDOO use
public struct AccountModifications {
    public let modifiedDetails: ModifiedAccountDetails
    public let removedAccountDetails: [any AccountValueKey.Type] // TODO shall we transport the previous value to facilitate existing infrastructure?
}
