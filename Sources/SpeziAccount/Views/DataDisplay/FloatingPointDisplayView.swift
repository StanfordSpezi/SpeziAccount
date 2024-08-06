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


/// Displays the value of an `BinaryFloatingPoint`-based `AccountKey`.
public struct FloatingPointDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: BinaryFloatingPoint {
    private let value: Key.Value
    private let formatStyle: FloatingPointFormatStyle<Key.Value>?

    @Environment(\.locale)
    private var locale

    private var formatStyleValue: FloatingPointFormatStyle<Key.Value> {
        formatStyle ?? FloatingPointFormatStyle(locale: locale).precision(.fractionLength(2))
    }

    public var body: some View {
        ListRow(Key.name) {
            Text(value, format: formatStyleValue)
        }
    }

    /// Create a new display view.
    /// - Parameters:
    ///   - value: The value to display.
    ///   - formatStyle: The format style to use for displaying the floating point value.
    public init(
        _ value: Key.Value,
        format formatStyle: FloatingPointFormatStyle<Key.Value>? = nil
    ) {
        self.value = value
        self.formatStyle = formatStyle
    }

    /// Create a new display view.
    /// - Parameter value: The value to display.
    public init(_ value: Key.Value) {
        self.value = value
        self.formatStyle = nil
    }

    /// Create a new display view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The value to display.
    ///   - formatStyle: The format style to use for displaying the floating point value.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Key.Value, format formatStyle: FloatingPointFormatStyle<Key.Value>? = nil) {
        self.init(value, format: formatStyle)
    }
}


extension AccountKey where Value: BinaryFloatingPoint {
    /// Default DataDisplay for `BinaryFloatingPoint`-based values.
    public typealias DataDisplay = FloatingPointDisplayView<Self>
}

#if DEBUG
#Preview {
    List {
        FloatingPointDisplayView<MockDoubleKey>(3.12456)
        FloatingPointDisplayView<MockDoubleKey>(533.124)
    }
}
#endif
