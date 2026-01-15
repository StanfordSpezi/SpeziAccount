//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// View and modify the currently associated user account details.
///
/// This provides an overview of the current account details. Further, it allows the user to modify their
/// account values.
///
/// - Important: This view requires to be placed inside a [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack/)
///     to work properly.
///
/// This view requires a currently logged in user (see ``Account/details``).
///
/// Below is a short code example on how to use the `AccountOverview` view.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         NavigationStack {
///             AccountOverview()
///         }
///     }
/// }
/// ```
///
/// Optionally, additional sections can be passed to AccountOverview within the trailing closure, providing the opportunity for customization and extension of the view."
/// Below is a short code example.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         NavigationStack {
///             AccountOverview {
///                 NavigationLink {
///                     // ... next view
///                 } label: {
///                     Text("General Settings")
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// ## Topics
/// ### Configuration
/// - ``CloseBehavior``
/// - ``AccountDeletionBehavior``
/// - ``init(close:deletion:additionalSections:)``
@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct AccountOverview<AdditionalSections: View>: View {
    /// Defines the behavior for the close button.
    public enum CloseBehavior {
        /// No close button is shown.
        case disabled
        /// A close button is shown that calls the `dismiss` action.
        case showCloseButton
    }
    
    
    /// How an account operation (i.e., logout or deletion) via the ``AccountOverview`` should be handled.
    public enum AccountOperationHandler {
        /// The operation should be handled normally via SpeziAccount.
        case `default`
        
        /// The operation should be handled via a custom closure.
        ///
        /// - parameter labels: The labels that should be used for UI related to the operation.
        /// - parameter handler: A closure used for handling the actual operation.
        case custom(
            labels: AccountOverviewOperationLabels,
            _ handler: @Sendable () async throws -> Void
        )
    }
    
    
    /// Defines the behavior of logging out of the account.
    public enum AccountLogoutBehavior: AccountOverviewDestructiveAccountOperation {
        /// Account logout is not available.
        case disabled
        /// Account logout is available.
        case enabled(AccountOperationHandler)
        
        typealias ExtraSections = AdditionalSections
        
        /// The default behavior, where logout is available and uses the SpeziAccount-defined labels and handler.
        public static var enabled: Self {
            .enabled(.default)
        }
        
        var labels: AccountOverviewOperationLabels {
            switch self {
            case .disabled, .enabled(.default):
                .logout
            case .enabled(.custom(let labels, _)):
                labels
            }
        }
        
        var handler: AccountOperationHandler? {
            switch self {
            case .disabled:
                nil
            case .enabled(let handler):
                handler
            }
        }
    }
    
    
    /// Defines the behavior of deleting the account.
    public enum AccountDeletionBehavior: AccountOverviewDestructiveAccountOperation {
        /// Account deletion is not available.
        case disabled
        /// When entering the edit mode, the logout button turns into a delete account button.
        case inEditMode(AccountOperationHandler)
        /// Show the delete button below the logout button.
        case belowLogout(AccountOperationHandler)
        
        typealias ExtraSections = AdditionalSections
        
        /// When entering the edit mode, the logout button turns into a delete account button.
        public static var inEditMode: Self {
            .inEditMode(.default)
        }
        
        /// Show the delete button below the logout button.
        public static var belowLogout: Self {
            .belowLogout(.default)
        }
        
        /// The labels that should be used for account-deletion-related UI elements.
        /// Exists to allow user customization.
        var labels: AccountOverviewOperationLabels {
            switch self {
            case .disabled, .belowLogout(.default), .inEditMode(.default):
                .deletion
            case .belowLogout(.custom(let labels, _)), .inEditMode(.custom(let labels, _)):
                labels
            }
        }
        
        var handler: AccountOperationHandler? {
            switch self {
            case .disabled:
                nil
            case .inEditMode(let handler), .belowLogout(let handler):
                handler
            }
        }
    }
    
    
    private let closeBehavior: CloseBehavior
    private let logoutBehavior: AccountLogoutBehavior
    private let deletionBehavior: AccountDeletionBehavior
    private let additionalSections: AdditionalSections

    @Environment(Account.self)
    private var account

    @State private var model: AccountOverviewFormViewModel?

    public var body: some View {
        ZStack {
            if let model {
                AccountOverviewForm(
                    model: model,
                    closeBehavior: closeBehavior,
                    logoutBehavior: logoutBehavior,
                    deletionBehavior: deletionBehavior,
                    additionalSections: additionalSections
                )
            }
            if account.details == nil {
                MissingAccountDetailsWarning()
            }
        }
        .onChange(of: account.signedIn, initial: true) {
            if let details = account.details {
                if model == nil {
                    model = AccountOverviewFormViewModel(account: account, details: details)
                }
            } else {
                model = nil
            }
        }
    }
    
    
    /// Display a new Account Overview.
    /// - Parameters:
    ///   - closeBehavior: Define the behavior of the close button that can be rendered in the toolbar. This is useful when presenting the AccountOverview
    ///     as a sheet. Disabled by default.
    ///   - deletionBehavior: Define how the Account Overview offers the user to delete their account. By default the Logout button turns into a delete button when entering edit mode.
    ///   - additionalSections: Optional additional sections displayed between the other AccountOverview information and the log out button.
    public init(
        close closeBehavior: CloseBehavior = .disabled,
        logout logoutBehavior: AccountLogoutBehavior = .enabled,
        deletion deletionBehavior: AccountDeletionBehavior = .inEditMode,
        @ViewBuilder additionalSections: () -> AdditionalSections = { EmptyView() }
    ) {
        self.closeBehavior = closeBehavior
        self.logoutBehavior = logoutBehavior
        self.deletionBehavior = deletionBehavior
        self.additionalSections = additionalSections()
    }
}


#if DEBUG && !os(macOS) && !os(watchOS)
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return NavigationStack {
        AccountOverview {
            NavigationLink {
                Text(verbatim: "")
                    .navigationTitle(Text(verbatim: "Settings"))
            } label: {
                Text(verbatim: "General Settings")
            }
            NavigationLink {
                Text(verbatim: "")
                    .navigationTitle(Text(verbatim: "Package Dependencies"))
            } label: {
                Text(verbatim: "License Information")
            }
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    NavigationStack {
        AccountOverview()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
