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
    static func emptyDataEntryView<Storage: AccountValues>(for container: Storage.Type) -> AnyView {
        AnyView(GeneralizedDataEntryView<DataEntry, Storage>(initialValue: emptyValue))
    }

    static func dataEntryViewWithCurrentStoredValue<Storage: AccountValues>(
        details: AccountDetails,
        for container: Storage.Type
    ) -> AnyView? {
        guard let value = details.storage.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<DataEntry, Storage>(initialValue: value))
    }

    static func dataEntryViewFromBuilder<Storage: AccountValues>(
        builder: ModifiedAccountDetails.Builder,
        for container: Storage.Type
    ) -> AnyView? {
        guard let value = builder.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<DataEntry, Storage>(initialValue: value))
    }

    static func dataDisplayViewWithCurrentStoredValue(from details: AccountDetails) -> AnyView? {
        guard let value = details.storage.get(Self.self) else {
            return nil
        }

        return AnyView(DataDisplay(value))
    }
}
