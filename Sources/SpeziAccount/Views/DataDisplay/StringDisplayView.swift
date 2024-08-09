//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI


/// Displays the value of an `String`-based `AccountKey`.
public struct StringDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: StringProtocol {
    private let value: Key.Value

    public var body: some View {
        ListRow(Key.name) {
            Text(value)
        }
    }

    /// Create a new display view.
    /// - Parameter value: The value to display.
    public init(_ value: Key.Value) {
        self.value = value
    }

    /// Create a new display view.
    /// - Parameters:
    ///   - keyPath: The `AccountKey` type.
    ///   - value: The value to display.
    @MainActor
    public init(_ keyPath: KeyPath<AccountKeys, Key.Type>, _ value: Key.Value) {
        self.init(value)
    }
}


extension AccountKey where Value: StringProtocol {
    /// Default DataDisplay for `String`-based values.
    public typealias DataDisplay = StringDisplayView<Self>
}


#if DEBUG
#Preview {
    List {
        StringDisplayView(\.userId, "leland.stanford")
    }
}
#endif