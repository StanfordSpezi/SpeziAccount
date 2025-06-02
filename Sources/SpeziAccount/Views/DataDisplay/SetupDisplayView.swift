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

/// A view that handles setup and display of an `AccountKey`.
///
/// While a ``DataDisplayView`` is only displayed, if a value is present in the ``AccountDetails`` of a user,
/// this view is also displayed to set up a account value that is not yet added to the account details of a user.
///
/// This view is used in the ``AccountOverview`` to show a setup interface for account keys
/// that don't have a stored value yet.
public protocol SetupDisplayView<Value>: DataDisplayView {
    /// Create a new setup display view.
    /// - Parameters:
    ///   - value: The current account value or `nil`, if the account details do not have a value for the given `AccountKey`.
    @MainActor
    init(_ value: Value?)
}

extension SetupDisplayView {
   public init(_ value: Value) { // default implementation for `DataDisplayView`.
      self.init(.some(value))
   }
}
