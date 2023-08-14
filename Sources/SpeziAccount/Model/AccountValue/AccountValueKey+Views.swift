//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


// TODO supply default DataEntryViews?

extension AccountValueKey where Value: StringProtocol {
    public typealias DataDisplay = StringDataDisplayView<Self>
}

extension AccountValueKey where Value: CustomLocalizedStringResourceConvertible {
    public typealias DataDisplay = LocalizableStringConvertibleDataDisplayView<Self>
}


extension AccountValueKey {
    static func emptyDataEntryView<Storage: AccountValueStorageContainer>(for container: Storage.Type) -> AnyView {
        AnyView(GeneralizedDataEntryView<DataEntry, Storage>(initialValue: emptyValue))
    }

    static func dataEntryViewWithCurrentStoredValue<Storage: AccountValueStorageContainer>(
        from details: AccountDetails,
        for container: Storage.Type
    ) -> AnyView? {
        // This is the reason for the `Stored` part of this method. We will only consider
        // values that are actually stored in the AccountDetails, ignoring computed ones.
        guard let value = details.storage.get(Self.self) else {
            // TODO is this a problem for computed values?
            return nil
        }

        return AnyView(GeneralizedDataEntryView<DataEntry, Storage>(initialValue: value))
    }

    static func dataDisplayViewWithCurrentStoredValue(from details: AccountDetails) -> AnyView? {
        guard let value = details.storage.get(Self.self) else {
            return nil // TODO make something to just retrieve the current stored value?
        }

        return AnyView(DataDisplay(value))
    }
}
