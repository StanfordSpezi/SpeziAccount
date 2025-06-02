//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziViews
import SwiftUI

/// A view that can be displayed for a display-only AccountKey when no value is stored.
///
/// This view is used in the ``AccountOverview`` to show a setup interface for account keys
/// that don't have a stored value yet.
public protocol SetupDisplayView: DataDisplayView {
    /// Create a new setup display view.
    /// - Parameters:
    ///   - value: The current account value or nil.
    @MainActor
    init(_ value: Value?)
}

extension SetupDisplayView {
   init(_ value: Value) {
      self.init(.some(value))
   }
}
