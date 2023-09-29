//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// The essential ``SpeziAccount`` view to view and modify the active account details.
///
/// This provides an overview of the current account details. Further, it allows the user to modify their
/// account values.
///
/// - Important: This view requires to be placed inside a [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack/)
///     to work properly.
///
/// This view requires a currently logged in user (see ``Account/details``).
/// Further, this view relies on an ``Account`` object in its environment. This is done automatically by providing a
/// ``AccountConfiguration`` in the configuration section of your `Spezi` app delegate.
///
/// - Note: In SwiftUI previews you can easily instantiate your own ``Account``. Use the ``Account/init(building:active:configuration:)``
///     initializer to create a new `Account` object with active ``AccountDetails``.
///
/// Below is a short code example on how to use the `AccountOverview` view.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         AccountOverview()
///     }
/// }
/// ```
///
/// Optionally, additional views can be passed to AccountOverview within the trailing closure, providing the opportunity for customization and extension of the view."
/// Below is a short code example.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         AccountOverview {
///             NavigationLink {
///                 // ... next view
///             } label: {
///                 Text("General Settings")
///             }
///         }
///     }
/// }
/// ```
///
/// - Note: The ``init(isEditing:)`` initializer allows to pass an optional `Bool` Binding to retrieve the
///     current edit mode of the view. This can be helpful to, e.g., render a custom `Close` Button if the
///     view is not editing when presenting the AccountOverview in a sheet.


public struct AccountOverview<Content: View>: View {
    @EnvironmentObject private var account: Account
    
    @Binding private var isEditing: Bool
    
    let additionalContent: Content
    
    public var body: some View {
        VStack {
            if let details = account.details {
                Form {
                    // Splitting everything into a separate subview was actually necessary for the EditMode to work.
                    // Not even the example that Apple provides for the EditMode works. See https://developer.apple.com/forums/thread/716434
                    AccountOverviewSections(
                        account: account,
                        details: details,
                        isEditing: $isEditing
                    ) {
                        additionalContent
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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    /// Display a new Account Overview.
    /// - Parameter isEditing: A Binding that allows you to read the current editing state of the Account Overview view.
    public init(isEditing: Binding<Bool> = .constant(false), @ViewBuilder additionalContent: () -> Content) {
        self._isEditing = isEditing
        self.additionalContent = additionalContent()
    }
}

/// Makes passing additionalContent optional
extension AccountOverview where Content == EmptyView {
    init(isEditing: Binding<Bool> = .constant(false)) {
        self._isEditing = isEditing
        self.additionalContent = EmptyView()
    }
}


#if DEBUG
struct AccountOverView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)
    
    static var previews: some View {
        NavigationStack {
            AccountOverview {
                NavigationLink {
                    Text("")
                        .navigationTitle(Text("Settings"))
                } label: {
                    Text("General Settings")
                }
                NavigationLink {
                    Text("")
                        .navigationTitle(Text("Package Dependencies"))
                } label: {
                    Text("License Information")
                }
            }
        }
        .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
        
        NavigationStack {
            AccountOverview()
        }
        .environmentObject(Account())
    }
}
#endif
