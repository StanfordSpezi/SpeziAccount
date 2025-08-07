//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// Displays the value of an `AccountKey`.
///
/// This view is typically placed as a row in the ``AccountOverview`` view.
///
/// - Note: Refer to the <doc:Adding-new-Account-Values> article for an overview of default implemented display views.
public protocol DataDisplayView<Value>: View, Sendable {
    /// The value type that is getting displayed
    associatedtype Value

    /// Create a new display view.
    /// - Parameters:
    ///   - value: The current account value.
    @MainActor
    init(_ value: Value)
}
