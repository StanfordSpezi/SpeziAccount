//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI

struct SetupButtonStringView: SetupDisplayView {
    typealias Value = String

    @Environment(InMemoryAccountStorageProvider.self)
    private var externalAccountStorage
    @Environment(Account.self)
    private var account

    private let value: String?

    @State private var viewState: ViewState = .idle

    var body: some View {
        if let value {
            LabeledContent("Value", value: value)
                .accessibilityElement(children: .combine)
        } else {
            AsyncButton("Guided Setup", state: $viewState) {
                guard let details = account.details else {
                    return
                }

                var modifications = AccountDetails()
                modifications.setupDisplayOnly = "Hello, World!"
                try await externalAccountStorage.simulateRemoteUpdate(for: details.accountId, AccountModifications(modifiedDetails: modifications))
            }
        }
    }

    init(_ value: String?) {
        self.value = value
    }
}


extension AccountDetails {
    @AccountKey(name: "Display-Only", options: .display, as: String.self)
    var displayOnlyOption: String?

    @AccountKey(name: "Mutable-Only", options: .mutable, as: String.self)
    var mutableOnlyOption: String?

    @AccountKey(name: "Setup-Display-Only", options: .display, as: String.self, displayView: SetupButtonStringView.self)
    var setupDisplayOnly: String?
}


@KeyEntry(\.displayOnlyOption, \.mutableOnlyOption, \.setupDisplayOnly)
extension AccountKeys {}
