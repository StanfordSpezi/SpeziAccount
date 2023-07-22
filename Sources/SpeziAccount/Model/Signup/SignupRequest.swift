//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public struct SignupRequest: Sendable, AccountValueStorageContainer {
    public typealias Builder = AccountValueStorageBuilder<Self>

    public let storage: AccountValueStorage

    init(storage: AccountValueStorage) {
        self.storage = storage
    }
}