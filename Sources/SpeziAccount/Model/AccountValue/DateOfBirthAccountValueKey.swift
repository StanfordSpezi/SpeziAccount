//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct DateOfBirthAccountValueKey: OptionalAccountValueKey {
    public typealias Value = Date
}

extension AccountValueStorageContainer {
    public var dateOfBrith: DateOfBirthAccountValueKey.Value? {
        storage[DateOfBirthAccountValueKey.self]
    }
}

extension ModifiableAccountValueStorageContainer {
    public var dateOfBrith: DateOfBirthAccountValueKey.Value? {
        get {
            storage[DateOfBirthAccountValueKey.self]
        }
        set {
            storage[DateOfBirthAccountValueKey.self] = newValue
        }
    }
}
