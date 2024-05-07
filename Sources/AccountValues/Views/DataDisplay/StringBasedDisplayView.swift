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


/// A ``DataDisplayView`` implementation for all ``AccountKey`` `Value` types that conform to `StringProtocol`.
public struct StringBasedDisplayView<Key: AccountKey>: DataDisplayView where Key.Value: StringProtocol {
    private let value: Key.Value

    public var body: some View {
        ListRow(Key.name) {
            Text(value)
        }
    }

    public init(_ value: Key.Value) {
        self.value = value
    }
}


#if DEBUG
#Preview {
    List {
        EmptyView() // TODO: StringBasedDisplayView<UserIdKey>("andreas.bauer")
    }
}
#endif
