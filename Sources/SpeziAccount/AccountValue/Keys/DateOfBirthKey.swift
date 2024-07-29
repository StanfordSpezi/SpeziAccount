//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


extension AccountDetails {
    /// The date of birth of a user.
    @AccountKey(
        name: LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .atURL(from: .module)),
        category: .personalDetails,
        initial: .empty(Date())
    )
    public var dateOfBirth: Date?
}


@KeyEntry(\.dateOfBirth)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier

// MARK: - UI

extension AccountDetails.__Key_dateOfBirth {
    public struct DataDisplay: DataDisplayView {
        private let value: Date

        @Environment(\.locale)
        private var locale

        private var formatStyle: Date.FormatStyle {
            .init()
                .locale(locale)
                .year(.defaultDigits)
                .month(locale.identifier == "en_US" ? .abbreviated : .defaultDigits)
                .day(.defaultDigits)
        }

        public var body: some View {
            ListRow(AccountKeys.dateOfBirth.name) {
                Text(value.formatted(formatStyle))
            }
        }

        public init(_ value: Date) {
            self.value = value
        }
    }

    public struct DataEntry: DataEntryView {
        @Binding private var value: Date

        @Environment(Account.self)
        private var account
        @Environment(\.accountViewType)
        private var viewType

        public var isRequired: Bool {
            account.configuration[AccountKeys.dateOfBirth]?.requirement == .required
            || viewType?.enteringNewData == false
        }

        public var body: some View {
            DateOfBirthPicker(AccountKeys.dateOfBirth.name, date: $value, isRequired: isRequired)
        }

        public init(_ value: Binding<Value>) {
            self._value = value
        }
    }
}
