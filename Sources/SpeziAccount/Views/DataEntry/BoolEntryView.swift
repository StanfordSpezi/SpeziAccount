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


/// Entry or modify the value of an `String`-based `AccountKey`.
public struct BoolEntryView<Key: AccountKey>: DataEntryView where Key.Value == Bool {
    @Binding private var value: Key.Value


    public var body: some View {
        Toggle(isOn: $value) {
            Text(Key.name)
        }
    }


    /// Create a new entry view.
    /// - Parameter value: The binding to the value to modify.
    public init(_ value: Binding<Key.Value>) {
        self._value = value
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


extension AccountKey where Value == Bool {
    /// Default DataEntry for `Bool`-based values.
    ///
    /// Renders a `Toggle` to change the bool value.
    public typealias DataEntry = BoolEntryView<Self>
}


#if DEBUG
#Preview {
    @Previewable @State var value = false
    Form {
        BoolEntryView<MockBoolKey>($value)
    }
}

#Preview {
    @Previewable @State var value = true
    Form {
        BoolEntryView<MockBoolKey>($value)
    }
}
#endif
