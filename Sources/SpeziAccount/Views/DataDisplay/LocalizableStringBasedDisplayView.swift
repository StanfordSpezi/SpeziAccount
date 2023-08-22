//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// A ``DataDisplayView`` implementation for all ``AccountKey`` `Value` types that conform to `CustomLocalizedStringResourceConvertible`.
public struct LocalizableStringBasedDisplayView<Key: AccountKey>: DataDisplayView
    where Key.Value: CustomLocalizedStringResourceConvertible {
    private let value: Key.Value

    public var body: some View {
        SimpleTextRow(name: Key.name) {
            Text(value.localizedStringResource)
        }
    }


    public init(_ value: Key.Value) {
        self.value = value
    }
}


#if DEBUG
struct LocalizableStringBasedDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizableStringBasedDisplayView<GenderIdentityKey>(.preferNotToState)
    }
}
#endif
