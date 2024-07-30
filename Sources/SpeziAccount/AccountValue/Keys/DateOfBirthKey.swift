//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


private struct DisplayView: DataDisplayView {
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

    var body: some View {
        ListRow(AccountKeys.dateOfBirth.name) {
            Text(value.formatted(formatStyle))
        }
    }

    init(_ value: Date) {
        self.value = value
    }
}

private struct EntryView: DataEntryView {
    @Binding private var value: Date

    @Environment(Account.self)
    private var account
    @Environment(\.accountViewType)
    private var viewType

    private var isRequired: Bool {
        account.configuration.dateOfBirth?.requirement == .required
        || viewType?.enteringNewData == false
    }

    var body: some View {
        DateOfBirthPicker(AccountKeys.dateOfBirth.name, date: $value, isRequired: isRequired)
    }

    init(_ value: Binding<Date>) {
        self._value = value
    }
}


extension AccountDetails {
    /// The date of birth of a user.
    @AccountKey(
        name: LocalizedStringResource("UAP_SIGNUP_DATE_OF_BIRTH_TITLE", bundle: .atURL(from: .module)),
        category: .personalDetails,
        as: Date.self,
        initial: .empty(Date()),
        displayView: DisplayView.self,
        entryView: EntryView.self
    )
    public var dateOfBirth: Date?
}


@KeyEntry(\.dateOfBirth)
public extension AccountKeys {} // swiftlint:disable:this no_extension_access_modifier
