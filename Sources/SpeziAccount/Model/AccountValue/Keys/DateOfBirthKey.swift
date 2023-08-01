//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct DateOfBirthKey: AccountValueKey {
    public typealias Value = Date
    public typealias DataEntry = DateOfBirthPicker

    public static let signupCategory: SignupCategory = .personalDetails
}

extension AccountValueKeys {
    public var dateOfBirth: DateOfBirthKey.Type {
        DateOfBirthKey.self
    }
}


extension AccountValueStorageContainer {
    public var dateOfBrith: DateOfBirthKey.Value? {
        storage[DateOfBirthKey.self]
    }
}


extension ModifiableAccountValueStorageContainer {
    public var dateOfBrith: DateOfBirthKey.Value? {
        get {
            storage[DateOfBirthKey.self]
        }
        set {
            storage[DateOfBirthKey.self] = newValue
        }
    }
}


// MARK: - UI
extension DateOfBirthPicker: DataEntryView {
    public typealias Key = DateOfBirthKey

    public init(_ value: Binding<Key.Value>) {
        self.init(date: value)
    }
}
