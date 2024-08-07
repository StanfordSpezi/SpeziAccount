//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The preferred style of presenting account setup views.
///
/// Some views provided by an ``AccountService`` to the ``AccountSetup`` views support different presentation styles.
/// In some situations, views might be able to present themselves such that login or signup operations are favored.
/// For example, an `AccountSetup` view that is displayed in the onboarding flow, might favor a presentation that highlights signup functionality.
///
/// - Note: Use the ``SwiftUI/View/preferredAccountSetupStyle(_:)`` to set the preferred account setup style.
public enum PreferredSetupStyle {
    /// Let the view automatically decide on how to present itself.
    ///
    /// For example, if login is not supported, the view might automatically choose to show the signup variant of the view.
    case automatic
    /// Prefer to show a view that supports a login flow.
    case login
    /// Prefer to show a view that supports a signup flow.
    case signup
}


extension EnvironmentValues {
    private struct PreferredSetupStyleKey: EnvironmentKey {
        static let defaultValue: PreferredSetupStyle = .automatic
    }

    /// The preferred style of presenting account setup views.
    var preferredSetupStyle: PreferredSetupStyle {
        get {
            self[PreferredSetupStyleKey.self]
        }
        set {
            self[PreferredSetupStyleKey.self] = newValue
        }
    }
}


extension PreferredSetupStyle: Sendable, Hashable {}


extension View {
    /// Set the preferred style of presenting account setup views for the view hierarchy.
    /// - Parameter setupStyle: The preferred account setup style.
    ///
    /// ## Topics
    /// - ``PreferredSetupStyle``
    public func preferredAccountSetupStyle(_ setupStyle: PreferredSetupStyle) -> some View {
        environment(\.preferredSetupStyle, setupStyle)
    }
}
