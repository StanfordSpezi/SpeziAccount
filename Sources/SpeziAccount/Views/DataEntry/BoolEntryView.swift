//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI


public struct BoolEntryView<Key: AccountKey>: DataEntryView where Key.Value == Bool {
    @Binding private var value: Key.Value


    public var body: some View {
        Toggle(isOn: $value) {
            Text(Key.name)
        }
    }


    public init(_ value: Binding<Key.Value>) {
        self._value = value
    }

    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Binding<Key.Value>) {
        self.init(value)
    }
}


extension AccountKey where Value == Bool {
    /// Default DataEntry for `Bool`-based values.
    ///
    /// Renders a `Toggle` to change the bool value.
    public typealias DataEntry = BoolEntryView<Self>
}


#if DEBUG
#Preview {
    @State var value = false
    return Form {
        BoolEntryView<MockBoolKey>($value)
    }
}

#Preview {
    @State var value = true
    return Form {
        BoolEntryView<MockBoolKey>($value)
    }
}
#endif
