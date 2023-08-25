//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The mode in which a subview of a ``AccountOverview`` operates in.
public enum OverviewEntryMode {
    /// New data is entered.
    case new
    /// Existing data is provided to the ``DataEntryView``.
    case existing
    /// Data is used to display data.
    case display
}


/// Defines the type of `SpeziAccount` view a ``DataEntryView`` or ``DataDisplayView`` is placed in.
public enum AccountViewType: EnvironmentKey {
    /// The view is part of a ``SignupForm`` view hierarchy.
    case signup
    /// The view is part of a ``AccountOverview`` view hierarchy in a given ``OverviewEntryMode``.
    case overview(mode: OverviewEntryMode)


    public static var defaultValue: AccountViewType?


    /// Determines if the view type represents a view mode where new data is provided for an account value.
    public var enteringNewData: Bool {
        switch self {
        case.signup:
            return true
        case let .overview(mode):
            return mode == .new
        }
    }
}


extension EnvironmentValues {
    /// The type of `SpeziAccount` view a ``DataEntryView`` or ``DataDisplayView`` is placed in.
    public var accountViewType: AccountViewType? {
        get {
            self[AccountViewType.self]
        }
        set {
            self[AccountViewType.self] = newValue
        }
    }
}
