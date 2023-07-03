//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct UserInfo: Sendable, ModifiableAccountValueStorageContainer {
    public var storage: AccountValueStorage

    public init(storage: AccountValueStorage) {
        self.storage = storage

        // patch the storage to make sure we don't expose the plaintext password
        self.storage.contents[ObjectIdentifier(PasswordAccountValueKey.self)] = nil
    }
}
