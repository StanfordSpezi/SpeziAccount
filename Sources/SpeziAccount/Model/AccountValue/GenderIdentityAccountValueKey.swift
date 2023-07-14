//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public struct GenderIdentityAccountValueKey: OptionalAccountValueKey {
    public typealias Value = GenderIdentity
}

extension AccountValueStorageContainer {
    public var genderIdentity: GenderIdentityAccountValueKey.Value? {
        storage[GenderIdentityAccountValueKey.self]
    }
}

extension ModifiableAccountValueStorageContainer {
    public var genderIdentity: GenderIdentityAccountValueKey.Value? {
        get {
            storage[GenderIdentityAccountValueKey.self]
        }
        set {
            storage[GenderIdentityAccountValueKey.self] = newValue
        }
    }
}