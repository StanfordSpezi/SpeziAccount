//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// A view that displays the current value of a given ``AccountKey`` implementation.
///
/// This view is default implemented for all ``AccountKey``s which value type is `String`-based or conforms
/// to [CustomLocalizedStringResourceConvertible](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible).
///  So before implementing one yourself verify if you might be able to rely on the default implementation.
///
/// This view is typically placed as a row in the ``AccountOverview`` view.
public protocol DataDisplayView<Value>: View {
    /// The value type that is getting displayed
    associatedtype Value

    /// Create a new display view.
    /// - Parameters:
    ///   - value: The current account value.
    @MainActor
    init(_ value: Value)
}
