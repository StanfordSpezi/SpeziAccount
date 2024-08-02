//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziValidation
import SwiftUI


public struct StringDataEntry<Key: AccountKey>: DataEntryView where Key.Value == String {
    @Binding private var value: String

    public var body: some View {
        VerifiableTextField(Key.name, text: $value)
            .disableAutocorrection(true)
    }


    public init(_ value: Binding<String>) {
        _value = value
    }

    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Binding<Key.Value>) {
        self.init(value)
    }
}


extension AccountKey where Value == String {
    /// Default DataEntry for `String`-based values.
    public typealias DataEntry = StringDataEntry<Self>
}


#if DEBUG
#Preview {
    @State var value = "Hello World"
    return List {
        StringDataEntry(\.userId, $value)
            .validate(input: value, rules: .nonEmpty)
    }
}
#endif
