//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A typed storage container to easily access any information for the currently signed in user.
///
/// Refer to ``AccountValueKey`` for a list of bundled `AccountValueKey`s.
public struct AccountInformation: Sendable, ModifiableAccountValueStorageContainer {
    // TODO think about modification?
    public typealias Builder = AccountValueStorageBuilder<Self>

    public var storage: AccountValueStorage

    public init(storage: AccountValueStorage) {
        self.storage = storage

        // patch the storage to make sure we make sure to not expose the plaintext password
        self.storage.contents[ObjectIdentifier(PasswordAccountValueKey.self)] = nil
    }
}
