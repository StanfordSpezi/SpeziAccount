//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI


/// Entry or modify the value of an `PickerValue`-based `AccountKey`.
///
/// For more information, refer to the documentation of `PickerValue`.
public struct CaseIterablePickerEntryView<Key: AccountKey>: DataEntryView where Key.Value: PickerValue, Key.Value.AllCases: RandomAccessCollection {
    @Binding private var value: Key.Value

    public var body: some View {
        CaseIterablePicker(Key.name, selection: $value)
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


extension AccountKey where Value: PickerValue, Value.AllCases: RandomAccessCollection {
    /// Default DataEntry view for Values that conform to `PickerValue` (typically useful with enums)
    public typealias DataEntry = CaseIterablePickerEntryView<Self>
}


#if DEBUG
#Preview {
    @Previewable @State var genderIdentity: GenderIdentity = .male

    Form {
        Grid {
            CaseIterablePickerEntryView(\.genderIdentity, $genderIdentity)
        }
    }
}

#Preview {
    @Previewable @State var genderIdentity: GenderIdentity = .male

    Grid {
        CaseIterablePickerEntryView(\.genderIdentity, $genderIdentity)
    }
        .padding(32)
#if !os(macOS) && !os(tvOS) && !os(watchOS)
        .background(Color(.systemGroupedBackground))
#endif
}
#endif
