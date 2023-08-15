//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public struct StringDataDisplayView<Key: AccountValueKey>: DataDisplayView where Key.Value: StringProtocol {
    private let value: Key.Value

    public var body: some View {
        SimpleTextRow(name: Key.name) {
            Text(value)
        }
    }

    public init(_ value: Key.Value) {
        self.value = value
    }
}


#if DEBUG
struct StringDataDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        StringDataDisplayView<UserIdKey>("andreas.bauer")
    }
}
#endif
