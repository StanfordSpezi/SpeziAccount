//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The date of birth of a user.
public struct DateOfBirthKey: AccountValueKey {
    public typealias Value = Date
    public typealias DataEntry = DateOfBirthPicker

    public static let category: AccountValueCategory = .personalDetails
}

extension AccountValueKeys {
    /// The date of birth ``AccountValueKey``.
    public var dateOfBirth: DateOfBirthKey.Type {
        DateOfBirthKey.self
    }
}


extension AccountValueStorageContainer {
    /// Access the date of birth of a user.
    public var dateOfBrith: Date? {
        storage[DateOfBirthKey.self]
    }
}


// MARK: - UI
extension DateOfBirthPicker: DataEntryView {
    public typealias Key = DateOfBirthKey

    public init(_ value: Binding<Key.Value>) {
        self.init(date: value)
    }
}
