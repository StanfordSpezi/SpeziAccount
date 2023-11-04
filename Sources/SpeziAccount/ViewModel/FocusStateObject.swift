//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// An `ObservableObject` that wraps a `FocusState` instance.
///
/// This is currently necessary as there is no viable mechanism to pass FocusState around.
///
/// - Note: This is only available in ``DataEntryView`` and ``DataDisplayView`` views.
@dynamicMemberLookup
class FocusStateObject: ObservableObject { // TODO: do we still need this?
    /// The `FocusState` of the parent view.
    /// Focus state is typically handled automatically using the ``AccountKey/focusState`` property.
    /// Access to this property is useful when defining a ``DataEntryView`` that exposes more than one field.
    let focusedField: FocusState<String?>.Binding // see `AccountKey.Type/focusState`


    /// Initializes a new FocusStateObject object.
    /// - Parameters:
    ///   - focusedField: The `FocusState` of the data entry view.
    init(focusedField: FocusState<String?>.Binding) {
        self.focusedField = focusedField
    }

    subscript<Member>(dynamicMember keyPath: KeyPath<FocusState<String?>.Binding, Member>) -> Member {
        focusedField[keyPath: keyPath]
    }

    subscript<Member>(dynamicMember keyPath: ReferenceWritableKeyPath<FocusState<String?>.Binding, Member>) -> Member {
        get {
            self[dynamicMember: keyPath as KeyPath<FocusState<String?>.Binding, Member>]
        }
        set {
            focusedField[keyPath: keyPath] = newValue
        }
    }
}
