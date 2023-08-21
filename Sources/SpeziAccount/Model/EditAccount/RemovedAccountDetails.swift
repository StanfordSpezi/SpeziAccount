//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// just another wrapper though which specific meaning!
public struct RemovedAccountDetails: Sendable, AccountValueStorageContainer {
    public let storage: AccountValueStorage


    public init(from storage: AccountValueStorage) {
        self.storage = storage
    }
}
