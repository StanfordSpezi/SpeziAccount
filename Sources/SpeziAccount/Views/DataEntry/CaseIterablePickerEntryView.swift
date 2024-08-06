//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// A account value that can be rendered as a picker (like enum values).
///
/// In order to provide an Automatic Picker ``DataEntryView``, conform your enum to [`CaseIterable`](https://developer.apple.com/documentation/swift/caseiterable)
/// to enumerate all cases, [`CustomLocalizedStringResourceConvertible`](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible)
/// to provide a localizable representation for each case and [`Hashable`](https://developer.apple.com/documentation/swift/hashable)
/// to differentiate cases.
public typealias PickerValue = CaseIterable & CustomLocalizedStringResourceConvertible & Hashable


// TODO: SpeziViews candidate?
struct CaseIterablePicker<Value: PickerValue, Label: View>: View where Value.AllCases: RandomAccessCollection {
    private let label: Label

    @Binding private var value: Value


    var body: some View {
        Picker(selection: $value) {
            ForEach(Value.allCases, id: \.hashValue) { value in
                Text(value.localizedStringResource)
                    .tag(value)
            }
        } label: {
            label
        }
    }

    init(value: Binding<Value>, @ViewBuilder label: () -> Label) {
        self._value = value
        self.label = label()
    }

    init(_ titleKey: LocalizedStringResource, value: Binding<Value>) where Label == Text {
        self.init(value: value) {
            Text(titleKey)
        }
    }
}


/// Entry or modify the value of an `PickerValue`-based `AccountKey`.
///
/// For more information, refer to the documentation of ``PickerValue``.
public struct CaseIterablePickerEntryView<Key: AccountKey>: DataEntryView where Key.Value: PickerValue, Key.Value.AllCases: RandomAccessCollection {
    @Binding private var value: Key.Value

    public var body: some View {
        CaseIterablePicker(Key.name, value: $value)
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
    /// Default DataEntry view for Values that conform to ``PickerValue`` (typically useful with enums)
    public typealias DataEntry = CaseIterablePickerEntryView<Self>
}


#if DEBUG
#Preview {
    @State var genderIdentity: GenderIdentity = .male

    return Form {
        Grid {
            CaseIterablePickerEntryView(\.genderIdentity, $genderIdentity)
        }
    }
}

#Preview {
    @State var genderIdentity: GenderIdentity = .male

    return Grid {
        CaseIterablePickerEntryView(\.genderIdentity, $genderIdentity)
    }
        .padding(32)
#if !os(macOS)
        .background(Color(.systemGroupedBackground))
#endif
}
#endif
