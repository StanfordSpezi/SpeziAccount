//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

public typealias PickerValue = CaseIterable & CustomLocalizedStringResourceConvertible & Hashable & Identifiable


public struct CaseIterablePicker<Value: PickerValue, Label: View>: View where Value.AllCases: RandomAccessCollection {
    private let label: Label

    @Binding private var value: Value


    public var body: some View {
        Picker(selection: $value) {
            ForEach(Value.allCases) { value in
                Text(value.localizedStringResource)
                    .tag(value)
            }
        } label: {
            label
        }
    }

    public init(value: Binding<Value>, @ViewBuilder label: () -> Label) {
        self._value = value // TODO: value: label name?
        self.label = label()
    }

    public init(_ titleKey: LocalizedStringResource, value: Binding<Value>) where Label == Text {
        self.init(value: value) {
            Text(titleKey)
        }
    }
}


import SpeziFoundation
public struct CaseIterablePickerEntryView<Key: AccountKey>: DataEntryView where Key.Value: PickerValue, Key.Value.AllCases: RandomAccessCollection {
    @Binding private var value: Key.Value

    public var body: some View {
        CaseIterablePicker(Key.name, value: $value)
    }

    public init(_ value: Binding<Key.Value>) {
        self._value = value
    }
}


// TODO: replae GenderIdentityPicker with the picker above!
/// A simple `Picker` implementation for ``GenderIdentity`` entry.
public struct GenderIdentityPicker: View {
    private let titleLocalization: LocalizedStringResource

    @Binding private var genderIdentity: GenderIdentity
    
    public var body: some View {
        Picker(
            selection: $genderIdentity,
            content: {
                ForEach(GenderIdentity.allCases) { genderIdentity in
                    Text(genderIdentity.localizedStringResource)
                        .tag(genderIdentity)
                }
            }, label: {
                Text(titleLocalization)
            }
        )
    }

    /// Initialize a new `GenderIdentityPicker`.
    /// - Parameters:
    ///   - genderIdentity: A binding to the ``GenderIdentity`` state.
    ///   - customTitle: Optionally provide a custom label text.
    public init(
        genderIdentity: Binding<GenderIdentity>,
        title customTitle: LocalizedStringResource? = nil
    ) {
        self._genderIdentity = genderIdentity
        self.titleLocalization = customTitle ?? GenderIdentityKey.name
    }
}


#if DEBUG
struct GenderIdentityPicker_Previews: PreviewProvider {
    @State private static var genderIdentity: GenderIdentity = .male
    
    
    static var previews: some View {
        Form {
            Grid {
                GenderIdentityPicker(genderIdentity: $genderIdentity)
            }
        }

        Grid {
            GenderIdentityPicker(genderIdentity: $genderIdentity)
        }
            .padding(32)
            .background(Color(.systemGroupedBackground))
    }
}
#endif
