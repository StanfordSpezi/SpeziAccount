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
public struct AccountOverview: View {
    @EnvironmentObject private var account: Account

    public var body: some View {
        ZStack {
            if let details = account.details {
                Form {
                    // Splitting everything into a separate subview was actually necessary for the EditMode to work.
                    // Not even the example that Apple provides for the EditMode works. See https://developer.apple.com/forums/thread/716434
                    AccountOverviewSections(
                        account: account,
                        details: details
                    )
                }
                    .submitLabel(.done)
                    .padding(.top, -20)
            } else {
                MissingAccountDetailsWarning()
                    .padding(.horizontal, MagicValue.outerHorizontalPadding)
            }
        }
            .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
    }


    /// Display a new Account Overview.
    public init() {}
}


#if DEBUG
struct AccountOverView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static var previews: some View {
        NavigationStack {
            AccountOverview()
        }
            .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))

        NavigationStack {
            AccountOverview()
        }
            .environmentObject(Account())
    }
}
#endif
