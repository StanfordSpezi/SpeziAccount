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


struct BiographyKey: AccountKey {
    typealias Value = String

    static let name: LocalizedStringResource = "Biography" // we don't bother to translate
    static let category: AccountKeyCategory = .personalDetails
}


extension AccountKeys {
    var biography: BiographyKey.Type {
        BiographyKey.self
    }
}


extension AccountValues {
    var biography: String? {
        storage[BiographyKey.self]
    }
}


extension BiographyKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = BiographyKey

        @Binding private var biography: Value

        public init(_ value: Binding<Value>) {
            self._biography = value
        }

        public var body: some View {
            VerifiableTextField(Key.name, text: $biography)
                .autocorrectionDisabled()
        }
    }
}
