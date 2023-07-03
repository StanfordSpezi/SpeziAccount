//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct NameAccountValueKey: AccountValueKey {
    public typealias Value = PersonNameComponents
}

extension AccountValueStorageContainer {
    public var name: NameAccountValueKey.Value {
        storage[NameAccountValueKey.self]
    }
}

extension ModifiableAccountValueStorageContainer {
    public var name: NameAccountValueKey.Value {
        get {
            storage[NameAccountValueKey.self]
        }
        set {
            storage[NameAccountValueKey.self] = newValue
        }
    }
}
