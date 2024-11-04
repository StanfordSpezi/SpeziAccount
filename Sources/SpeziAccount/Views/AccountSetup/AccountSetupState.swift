//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The state of the account setup process.
///
/// Use the ``AccountSetupState`` type instead.
@available(*, deprecated, renamed: "AccountSetupState", message: "Please use the `AccountSetupState` type directly.")
public typealias _AccountSetupState = AccountSetupState // swiftlint:disable:this type_name


/// The state of the account setup process.
///
/// This type models the different states of the ``AccountSetup`` view. You can retrieve this state using the
/// ``SwiftUICore/EnvironmentValues/accountSetupState`` environment variable in the `Header` view passed to `AccountSetup`.
public enum AccountSetupState {
    /// The signup view is presented to the user.
    case presentingSignup
    /// Additional information is required from the user.
    ///
    /// The ``FollowUpInfoSheet`` is currently presented to the user.
    case requiringAdditionalInfo(_ keys: [any AccountKey.Type])
    /// The existing account is currently being loaded.
    ///
    /// This state is entered while the `setupComplete` closure passed to ``AccountSetup/init(setupComplete:header:continue:)`` is getting executed.
    case loadingExistingAccount
    /// The currently associated account is presented.
    ///
    /// The user was already signed in or just got signed in successfully and is presented with their current user account.
    case presentingExistingAccount
    
    /// The currently associated account is presented.
    @available(
        *,
         deprecated,
         renamed: "presentingExistingAccount",
         message: "Please use the new `presentingExistingAccount` state or `isInSignup` property instead."
    )
    public static var generic: AccountSetupState {
        .presentingExistingAccount
    }
    
    /// Setup is currently shown to the user.
    @available(*, deprecated, renamed: "presentingSignup", message: "Please use the new `presentingSignup` state instead.")
    public static var setupShown: AccountSetupState {
        .presentingSignup
    }
    
    /// Determine if the user is currently in the signup process.
    public var isInSignup: Bool {
        switch self {
        case .presentingExistingAccount:
            false
        case .presentingSignup, .requiringAdditionalInfo, .loadingExistingAccount:
            true
        }
    }
    
    /// Pattern matching operator.
    /// - Parameters:
    ///   - lhs: The left hand side.
    ///   - rhs: The right hand side.
    /// - Returns: Returns `true` if `lhs` and `rhs` both represent the same case.
    public static func ~= (lhs: AccountSetupState, rhs: AccountSetupState) -> Bool {
        // allow pattern matching for deprecated states
        switch (lhs, rhs) {
        case (.presentingSignup, .presentingSignup):
            true
        case (.requiringAdditionalInfo, .requiringAdditionalInfo):
            true
        case (.loadingExistingAccount, .loadingExistingAccount):
            true
        case (.presentingExistingAccount, .presentingExistingAccount):
            true
        default:
            false
        }
    }
}


extension AccountSetupState: Sendable {}


extension EnvironmentValues {
    /// The current account setup state.
    ///
    /// This environment property can be retrieved for child views of the ``AccountSetup`` view to determine the current setup state.
    /// Use this in the `Header` view passed to ``AccountSetup/init(setupComplete:header:`continue`:)``.
    @Entry public var accountSetupState: AccountSetupState = .presentingSignup

    /// The current account setup state.
    @available(*, deprecated, renamed: "accountSetupState", message: "Please use the new `accountSetupState` directly.")
    public var _accountSetupState: _AccountSetupState {
        // swiftlint:disable:previous identifier_name
        get {
            accountSetupState
        }
        set {
            accountSetupState = newValue
        }
    }
}
