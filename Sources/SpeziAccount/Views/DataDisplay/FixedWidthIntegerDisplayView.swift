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


public struct FixedWidthIntegerDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: FixedWidthInteger {
    private let value: Key.Value

    public var body: some View {
        ListRow(Key.name) {
            Text(value.description)
        }
    }

    public init(_ value: Key.Value) {
        self.value = value
    }

    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Key.Value) {
        self.init(value)
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
