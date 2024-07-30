//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziValidation
import SwiftUI


extension AccountDetails {
    @AccountKey(name: "Biography", category: .personalDetails, as: String.self)
    var biography: String?
}


@KeyEntry(\.biography)
extension AccountKeys {}


extension AccountDetails.__Key_biography {
    public struct DataEntry: DataEntryView { // TODO: provide default UI for string entry?
        @Binding private var biography: Value

        public init(_ value: Binding<Value>) {
            self._biography = value
        }

        public var body: some View {
            VerifiableTextField(AccountDetails.__Key_biography.name, text: $biography)
                .autocorrectionDisabled()
        }
    }
}
