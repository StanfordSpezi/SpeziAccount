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


/// A ``DataDisplayView`` implementation for all ``AccountKey`` `Value` types that conform to
/// [CustomLocalizedStringResourceConvertible](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible).
public struct LocalizableStringBasedDisplayView<Key: AccountKey>: DataDisplayView
    where Key.Value: CustomLocalizedStringResourceConvertible {
    private let value: Key.Value

    public var body: some View {
        ListRow(Key.name) {
            Text(value.localizedStringResource)
        }
    }


    public init(_ value: Key.Value) {
        self.value = value
    }
}


extension Bool: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        .init(self ? "YES" : "NO", bundle: .atURL(from: .module))
    }
}


#if DEBUG
#Preview {
    Form {
        EmptyView() // TODO: LocalizableStringBasedDisplayView<GenderIdentityKey>(.preferNotToState)
    }
}
#endif
