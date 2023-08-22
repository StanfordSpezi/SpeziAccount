//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


extension AccountKey where Value: StringProtocol {
    public typealias DataDisplay = StringDataDisplayView<Self>
}

extension AccountKey where Value: CustomLocalizedStringResourceConvertible {
    public typealias DataDisplay = LocalizableStringConvertibleDataDisplayView<Self>
}


extension AccountKey {
    static func emptyDataEntryView<Values: AccountValues>(for values: Values.Type) -> AnyView {
        AnyView(GeneralizedDataEntryView<DataEntry, Values>(initialValue: emptyValue))
    }

    static func dataEntryViewWithCurrentStoredValue<Values: AccountValues>(
        details: AccountDetails,
        for values: Values.Type
    ) -> AnyView? {
        guard let value = details.storage.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<DataEntry, Values>(initialValue: value))
    }

    static func dataEntryViewFromBuilder<Values: AccountValues>(
        builder: ModifiedAccountDetails.Builder,
        for values: Values.Type
    ) -> AnyView? {
        guard let value = builder.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<DataEntry, Values>(initialValue: value))
    }

    static func dataDisplayViewWithCurrentStoredValue(from details: AccountDetails) -> AnyView? {
        guard let value = details.storage.get(Self.self) else {
            return nil
        }

        return AnyView(DataDisplay(value))
    }
}