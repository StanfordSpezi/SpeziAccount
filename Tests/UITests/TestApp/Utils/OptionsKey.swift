//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

struct SetupButtonStringView: SetupDisplayView {
    typealias Value = String

    private let value: String?

    var body: some View {
        if let value {
            LabeledContent("Value", value: value)
        } else {
            Button("Guided Setup") {}
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


// TODO: support syntax @KeyEntry(\.displayOnlyOption, \.mutableOnlyOption, \.setupDisplayOnly)
@KeyEntry(\.displayOnlyOption)
@KeyEntry(\.mutableOnlyOption)
@KeyEntry(\.setupDisplayOnly)
extension AccountKeys {}
