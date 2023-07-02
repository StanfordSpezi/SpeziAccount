//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public struct PasswordAccountValueKey: AccountValueKey {
    public typealias Value = String
}

extension AccountValueStorageContainer {
    public var password: PasswordAccountValueKey.Value {
        storage[PasswordAccountValueKey.self]
    }
}

extension ModifiableAccountValueStorageContainer {
    public var password: PasswordAccountValueKey.Value {
        get {
            storage[PasswordAccountValueKey.self]
        }
        set {
            storage[PasswordAccountValueKey.self] = newValue
        }
    }
}
