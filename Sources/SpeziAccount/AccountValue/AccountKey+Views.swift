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
    /// Default DataDisplay for String-based values using ``StringBasedDisplayView``.
    public typealias DataDisplay = StringBasedDisplayView<Self>
}

extension AccountKey where Value: CustomLocalizedStringResourceConvertible {
    /// Default DataDisplay for `CustomLocalizedStringResourceConvertible`-based values using ``LocalizableStringBasedDisplayView``.
    public typealias DataDisplay = LocalizableStringBasedDisplayView<Self>
}


extension AccountKey {
    static func emptyDataEntryView<Values: AccountValues>(for values: Values.Type) -> AnyView {
        AnyView(GeneralizedDataEntryView<DataEntry, Values>(initialValue: initialValue.value))
    }

    static func dataEntryViewWithStoredValueOrInitial<Values: AccountValues>(
        details: AccountDetails,
        for values: Values.Type
    ) -> AnyView {
        let value = details.storage.get(Self.self) ?? initialValue.value
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

    static func singleEditView(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) -> AnyView {
        AnyView(SingleEditView<Self>(model: model, details: accountDetails))
    }
}
