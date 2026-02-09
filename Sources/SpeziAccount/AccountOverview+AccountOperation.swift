//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


@available(macOS, unavailable)
@available(watchOS, unavailable)
protocol AccountOverviewDestructiveAccountOperation<ExtraSections> { // swiftlint:disable:this type_name
    associatedtype ExtraSections: View // cringe that we need to carry this around, but it's in a non-public type so ok for now
    
    var labels: AccountOverviewOperationLabels { get }
    var handler: AccountOverview<ExtraSections>.AccountOperationHandler? { get }
}


/// The labels that should be used for an account-related operation with a confirmation step (e.g., logout or deletion).
///
/// ## Topics
///
/// ### Default Configurations
/// - ``logout``
/// - ``deletion``
///
/// ### Initializers
/// - ``init(formButton:confirmationAlertTitle:confirmationAlertMessage:confirmationAlertSubmitButton:confirmationAlertCancelButton:)``
///
/// ### Static Properties
/// - ``cancelButtonTitle``
public struct AccountOverviewOperationLabels: Sendable {
    /// The default "Cancel" button title
    public static let cancelButtonTitle = LocalizedStringResource("Cancel", bundle: .module)
    
    let formButton: LocalizedStringResource
    let confirmationAlertTitle: LocalizedStringResource
    let confirmationAlertMessage: LocalizedStringResource?
    let confirmationAlertSubmitButton: LocalizedStringResource
    let confirmationAlertCancelButton: LocalizedStringResource
    
    /// Creates an instance that uses custom labels
    ///
    /// - parameter formButton: The title of the operation's form button in the ``AccountOverview``
    /// - parameter confirmationAlertTitle: The title of the operation's confirmation alert.
    /// - parameter confirmationAlertMessage: The message of the operation's confirmation alert.
    /// - parameter confirmationAlertSubmitButton: The title of the confirmation alert's primary button (i.e., the one that performs the operation).
    /// - parameter confirmationAlertCancelButton: The title of the confirmation alert's cancellation button.
    public init(
        formButton: LocalizedStringResource,
        confirmationAlertTitle: LocalizedStringResource,
        confirmationAlertMessage: LocalizedStringResource?,
        confirmationAlertSubmitButton: LocalizedStringResource,
        confirmationAlertCancelButton: LocalizedStringResource = Self.cancelButtonTitle
    ) {
        self.formButton = formButton
        self.confirmationAlertTitle = confirmationAlertTitle
        self.confirmationAlertMessage = confirmationAlertMessage
        self.confirmationAlertSubmitButton = confirmationAlertSubmitButton
        self.confirmationAlertCancelButton = confirmationAlertCancelButton
    }
}


extension AccountOverviewOperationLabels {
    /// The default labels for account logout
    public static let logout = Self(
        formButton: LocalizedStringResource("UP_LOGOUT", bundle: .module),
        confirmationAlertTitle: LocalizedStringResource("CONFIRMATION_LOGOUT", bundle: .module),
        confirmationAlertMessage: nil,
        confirmationAlertSubmitButton: LocalizedStringResource("UP_LOGOUT", bundle: .module)
    )
    
    /// The default labels for account deletion
    public static let deletion = Self(
        formButton: LocalizedStringResource("DELETE_ACCOUNT", bundle: .module),
        confirmationAlertTitle: LocalizedStringResource("CONFIRMATION_REMOVAL", bundle: .module),
        confirmationAlertMessage: LocalizedStringResource("CONFIRMATION_REMOVAL_SUGGESTION", bundle: .module),
        confirmationAlertSubmitButton: LocalizedStringResource("DELETE", bundle: .module)
    )
}
