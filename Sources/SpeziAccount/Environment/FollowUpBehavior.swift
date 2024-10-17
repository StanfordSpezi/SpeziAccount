//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Determine how the Follow-Up information sheet is presented after account setup.
///
/// Use the ``SwiftUICore/View/followUpBehaviorAfterSetup(_:)`` modifier to set how the follow-up information sheet is
/// shown inside the ``AccountSetup`` after a successful setup (login or signup).
public enum FollowUpBehavior {
    /// Follow up information will never be asked for after account setup.
    ///
    /// This will never present the ``FollowUpInfoSheet`` after account setup to ask for follow up information. This is useful if you
    /// want to define this flow yourself.
    /// - Warning: Use this option with care. If disabled, you might end up with ``AccountDetails`` that do not fulfill the requirements
    ///     specified in the ``AccountValueConfiguration``.
    case disabled
    /// The user is required to provide information for all required account keys.
    ///
    /// After a successful account setup (login or signup) the ``FollowUpInfoSheet`` will be presented if there are any missing required account keys.
    /// The user might be asked for keys with ``AccountKeyRequirement/collected`` requirement, if the identity provider is not capable of
    /// displaying all account keys and the user is a new user (if ``AccountDetails/isNewUser`` is set).
    case minimal
    /// The user is required to provide information for all required account keys while also asking for collected keys.
    ///
    /// After a successful account setup (login or signup) the ``FollowUpInfoSheet`` will be presented if there are any missing required account keys.
    /// In that case, the sheet will also display all account keys with ``AccountKeyRequirement/collected`` requirement that are not present yet.
    ///
    /// Collected account keys are also shown when not required key is missing, if the identity provider is not capable of displaying all account keys
    /// and the user is a new user (if ``AccountDetails/isNewUser`` is set).
    /// 
    /// - Note: With this option, the user might be repeatedly asked for optional account keys.
    case redundant


    /// The user is required to provide information for all required account keys.
    ///
    /// Automatically determines which behavior to choose.
    public static var automatic: FollowUpBehavior {
        .minimal
    }
}


extension FollowUpBehavior: Sendable, Hashable {}


extension EnvironmentValues {
    private struct FollowUpBehaviorKey: EnvironmentKey {
        static let defaultValue: FollowUpBehavior = .automatic
    }

    var followUpBehavior: FollowUpBehavior {
        get {
            self[FollowUpBehaviorKey.self]
        }
        set {
            self[FollowUpBehaviorKey.self] = newValue
        }
    }
}


extension View {
    /// Define how the follow-up information sheet is presented after a successful account setup.
    ///
    /// This modifier can be applied to a ``AccountSetup`` view to define the behavior of the ``FollowUpInfoSheet``.
    /// For more information refer to the documentation of ``FollowUpBehavior``.
    ///
    /// ```swift
    /// struct MyView: View {
    ///     var body: some View {
    ///         AccountSetup()
    ///             .followUpBehaviorAfterSetup(.redundant)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter behavior: The behavior that should be used on a successful account setup.
    /// - Returns: Returns the modified view.
    ///
    /// ## Topics
    /// - ``FollowUpBehavior``
    public func followUpBehaviorAfterSetup(_ behavior: FollowUpBehavior) -> some View {
        environment(\.followUpBehavior, behavior)
    }
}
