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


public struct BinaryIntegerDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: BinaryInteger {
    private let value: Key.Value

    public var body: some View {
        ListRow(Key.name) {
            Text(value.description)
        }
    }

    public init(_ value: Key.Value) {
        self.value = value
    }
}


extension AccountKey where Value: BinaryInteger {
    /// Default DataDisplay for `BinaryInteger`-based values.
    public typealias DataDisplay = BinaryIntegerDisplayView<Self>
}


#if DEBUG
#Preview {
    List {
        BinaryIntegerDisplayView<MockNumericKey>(3)
    }
}
#endif
