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

    public static let name = LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .atURL(from: .module))

    public static let category: AccountValueCategory = .personalDetails
}

extension AccountValueKeys {
    /// The date of birth ``AccountValueKey`` metatype.
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

extension DateOfBirthKey {
    public struct DataDisplay: DataDisplayView {
        public typealias Key = DateOfBirthKey

        private let value: Date

        @Environment(\.locale) private var locale

        private var formatStyle: Date.FormatStyle {
            .init()
                .locale(locale)
                .year(.defaultDigits)
                .month(locale.identifier == "en_US" ? .abbreviated : .defaultDigits)
                .day(.defaultDigits)
        }

        public var body: some View {
            Text(Key.name)
            Spacer()
            Text(value.formatted(formatStyle))
                .foregroundColor(.secondary)
        }


        public init(_ value: Date) {
            self.value = value
        }
    }
}

extension DateOfBirthPicker: DataEntryView {
    public typealias Key = DateOfBirthKey

    public init(_ value: Binding<Key.Value>) {
        self.init(date: value)
    }
}
