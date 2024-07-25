//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


@MainActor
extension AccountKey {
    static func emptyDataEntryView() -> AnyView {
        AnyView(GeneralizedDataEntryView<Self.DataEntry>(initialValue: initialValue.value))
    }

    static func dataEntryViewWithStoredValueOrInitial(details: AccountDetails) -> AnyView {
        let value = details.storage.get(Self.self) ?? initialValue.value
        return AnyView(GeneralizedDataEntryView<Self.DataEntry>(initialValue: value))
    }

    static func dataEntryViewFromBuilder(
        builder: AccountValuesBuilder
    ) -> AnyView? {
        guard let value = builder.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<Self.DataEntry>(initialValue: value))
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
