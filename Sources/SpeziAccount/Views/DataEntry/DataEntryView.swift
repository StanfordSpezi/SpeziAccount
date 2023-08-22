//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// A view that handles entry of a new value of a given ``AccountKey`` implementation.
///
/// This view is used in views like the ``SignupForm`` or ``AccountOverview`` to enter or modify a account value.
///
/// - Note: The ``AccountKey/emptyValue-10l6x`` is used in views like the ``SignupForm`` as the initial value for this view.
public protocol DataEntryView<Key>: View {
    /// The ``AccountKey`` this view receives a value for.
    associatedtype Key: AccountKey

    /// Creates a new data entry view.
    /// - Parameter value: A binding to store the current and change value.
    init(_ value: Binding<Key.Value>)
}
