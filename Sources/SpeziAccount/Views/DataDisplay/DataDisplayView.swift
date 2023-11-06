//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// A view that displays the current value of a given ``AccountKey`` implementation.
///
/// This view is default implemented for all ``AccountKey``s which value type is `String`-based or conforms
/// to [CustomLocalizedStringResourceConvertible](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible).
///  So before implementing one yourself verify if you might be able to rely on the default implementation.
///
/// This view is typically placed as a row in the ``AccountOverview`` view.
public protocol DataDisplayView<Key>: View {
    /// The ``AccountKey`` this view displays the value for.
    associatedtype Key: AccountKey

    /// Create a new display view.
    /// - Parameter value: The current account value.
    init(_ value: Key.Value)
}
