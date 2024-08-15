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


/// Entry or modify the value of an `String`-based `AccountKey`.
public struct StringEntryView<Key: AccountKey>: DataEntryView where Key.Value == String {
    @Binding private var value: String

    public var body: some View {
        VerifiableTextField(Key.name, text: $value)
            .disableAutocorrection(true)
    }


    /// Create a new entry view.
    /// - Parameter value: The binding to the value to modify.
    public init(_ value: Binding<String>) {
        _value = value
    }

    /// Create a new entry view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The binding to the value to modify.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Binding<Key.Value>) {
        self.init(value)
    }
}


extension AccountKey where Value == String {
    /// Default DataEntry for `String`-based values.
    public typealias DataEntry = StringEntryView<Self>
}


#if DEBUG
#Preview {
    @State var value = "Hello World"
    return List {
        StringEntryView(\.userId, $value)
            .validate(input: value, rules: .nonEmpty)
    }
}
#endif
