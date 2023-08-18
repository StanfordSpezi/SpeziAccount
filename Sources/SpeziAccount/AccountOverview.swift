//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


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
                    // TODO placement of those?
                    .submitLabel(.done) // TODO next label?
                    .padding(.top, -20)
            } else {
                Text("No active Account!")
                // TODO documentation link!
            }
        }
            .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
    }

    public init() {}
}


#if DEBUG
struct AccountOverView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static var previews: some View {
        NavigationStack {
            AccountOverview()
        }
            .environmentObject(Account(building: details, active: MockUserIdPasswordAccountService()))
    }
}
#endif
