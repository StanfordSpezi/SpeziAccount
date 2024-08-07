//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziViews
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
/// ### Close Button
/// - ``CloseBehavior``
@available(macOS, unavailable)
public struct AccountOverview<AdditionalSections: View>: View {
    /// Defines the behavior for the close button.
    public enum CloseBehavior {
        /// No close button is shown.
        case disabled
        /// A close button is shown that calls the `dismiss` action.
        case showCloseButton
    }

    private let closeBehavior: CloseBehavior
    private let additionalSections: AdditionalSections

    @Environment(Account.self)
    private var account

    
    public var body: some View {
        VStack {
            if let details = account.details {
                Form {
                    // Splitting everything into a separate subview was actually necessary for the EditMode to work.
                    // Not even the example that Apple provides for the EditMode works. See https://developer.apple.com/forums/thread/716434
                    AccountOverviewSections(
                        account: account,
                        details: details,
                        close: closeBehavior
                    ) {
                        additionalSections
                    }
                }
                    .padding(.top, -20)
            } else {
                Spacer()
                MissingAccountDetailsWarning()
                    .padding(.horizontal, ViewSizing.outerHorizontalPadding)
                Spacer()
                Spacer()
                Spacer()
            }
        }
            .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    
    /// Display a new Account Overview.
    /// - Parameters:
    ///   - isEditing: A Binding that allows you to read the current editing state of the Account Overview view.
    ///   - additionalSections: Optional additional sections displayed between the other AccountOverview information and the log out button.
    public init(close closeBehavior: CloseBehavior = .disabled, @ViewBuilder additionalSections: () -> AdditionalSections = { EmptyView() }) {
        self.closeBehavior = closeBehavior
        self.additionalSections = additionalSections()
    }
}


#if DEBUG && !os(macOS)
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
