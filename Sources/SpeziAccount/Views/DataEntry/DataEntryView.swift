//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// Handles entry of a new or existing value of an `AccountKey`.
///
/// This view is used in views like the ``SignupForm`` or ``AccountOverview`` to enter or modify a account value.
///
/// - Note: Refer to the <doc:Adding-new-Account-Values> article for an overview of default implemented display views.
public protocol DataEntryView<Value>: View {
    /// The type of value this view receives a value for.
    associatedtype Value

    /// Creates a new data entry view.
    /// - Parameter value: A binding to store the current and change value.
    @MainActor
    init(_ value: Binding<Value>)
}
