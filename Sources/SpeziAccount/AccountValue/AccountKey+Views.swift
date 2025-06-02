//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI

protocol AccountKeyWithSetupView {
    @MainActor
    func emptySetupView() -> AnyView
}

private struct AccountKeyTypeWrapper<Key: AccountKey> {
    init() {}
}


@MainActor
extension AccountKey {
    static func emptyDataEntryView() -> AnyView {
        AnyView(GeneralizedDataEntryView<Self>(initialValue: initialValue.value))
    }

    static func dataEntryViewWithStoredValueOrInitial(details: AccountDetails) -> AnyView {
        let value = details[Self.self] ?? initialValue.value
        return AnyView(GeneralizedDataEntryView<Self>(initialValue: value))
    }

    static func dataEntryViewFromBuilder(
        builder: AccountDetailsBuilder
    ) -> AnyView? {
        guard let value = builder.get(Self.self) else {
            return nil
        }

        return AnyView(GeneralizedDataEntryView<Self>(initialValue: value))
    }

    static func dataDisplayViewWithCurrentStoredValue(from details: AccountDetails) -> AnyView? {
        guard let value = details[Self.self] else {
            return nil
        }

        return AnyView(DataDisplay(value))
    }

    static func setupView() -> AnyView? {
        let typeWrapper = AccountKeyTypeWrapper<Self>()

        if let setupTypeWrapper = typeWrapper as? any AccountKeyWithSetupView {
            return setupTypeWrapper.emptySetupView()
        }
        return nil
    }

    static func singleEditView(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) -> AnyView {
        AnyView(SingleEditView<Self>(model: model, details: accountDetails))
    }
}

extension AccountKeyTypeWrapper: AccountKeyWithSetupView where Key.DataDisplay: SetupDisplayView {
    @MainActor
    func emptySetupView() -> AnyView {
        AnyView(Key.DataDisplay(nil))
    }
}

