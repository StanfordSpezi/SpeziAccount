//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


public struct BinaryIntegerDataEntry<Key: AccountKey>: DataEntryView where Key.Value: BinaryInteger {
    @Binding private var value: Key.Value


    public var body: some View {
        TextField(value: $value, formatter: NumberFormatter()) {
            Text(Key.name)
        }
            .keyboardType(.numberPad)
            .disableFieldAssistants()
        // TODO: requiredness!
    }

    public init(_ value: Binding<Key.Value>) {
        self._value = value
    }
}


extension AccountKey where Value: BinaryInteger {
    /// Default DataEntry for `BinaryInteger`-based values.
    public typealias DataEntry = BinaryIntegerDataEntry<Self>
}


#if DEBUG
#Preview {
    @State var value = 3
    return List {
        BinaryIntegerDataEntry<MockNumericKey>($value)
    }
}
#endif
