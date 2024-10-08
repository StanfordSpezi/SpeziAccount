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


/// Displays the value of an `FixedWidthInteger`-based `AccountKey`.
public struct FixedWidthIntegerDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: FixedWidthInteger {
    private let value: Key.Value
    private let unit: Text

    public var body: some View {
        ListRow(Key.name) {
            Text(value.description)
                + unit
        }
    }

    /// Create a new display view.
    /// - Parameters:
    ///   - value: The value to display.
    ///   - unit: A trailing unit label.
    public init(_ value: Key.Value, unit: Text = Text(verbatim: "")) {
        self.value = value
        self.unit = unit
    }

    /// Create a new display view.
    /// - Parameter value: The value to display.
    public init(_ value: Key.Value) {
        self.value = value
        self.unit = Text(verbatim: "")
    }

    /// Create a new display view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The value to display.
    ///   - unit: A trailing unit label.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Key.Value, unit: Text = Text(verbatim: "")) {
        self.init(value, unit: unit)
    }
}


extension AccountKey where Value: FixedWidthInteger {
    /// Default DataDisplay for `FixedWidthInteger`-based values.
    public typealias DataDisplay = FixedWidthIntegerDisplayView<Self>
}


#if DEBUG
#Preview {
    List {
        FixedWidthIntegerDisplayView<MockNumericKey>(3)
    }
}
#endif
