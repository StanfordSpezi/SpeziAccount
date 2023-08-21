//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


// just another wrapper though which specific meaning!
public struct RemovedAccountDetails: Sendable, AccountValues {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise

    public let storage: AccountStorage


    public init(from storage: AccountStorage) {
        self.storage = storage
    }
}
