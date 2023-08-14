//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// just another wrapper though which specific meaning!
public struct ModifiedAccountDetails: Sendable, AccountValueStorageContainer { // TODO support iterating over all keys and values!
    public let storage: AccountValueStorage


    fileprivate init(storage: AccountValueStorage) {
        self.storage = storage
    }
}


extension AccountValueStorageBuilder where Container == ModifiedAccountDetails {
    public func build() -> Container {
        ModifiedAccountDetails(storage: self.storage) // TODO allow password and userid to be modified?
    }
}
