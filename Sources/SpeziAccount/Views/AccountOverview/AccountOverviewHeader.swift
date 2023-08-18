//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct AccountOverviewHeader: View {
    private let details: AccountDetails


    var accountHeadline: String {
        // we gracefully check if the account details have a name, bypassing the subscript overloads
        if let name = details.name {
            return name.formatted(.name(style: .long))
        } else {
            // otherwise we display the userId
            return details.userId
        }
    }

    var accountSubheadline: String? {
        if details.name != nil {
            // If the accountHeadline uses the name, we display the userId as the subheadline
            return details.userId
        } else if details.userIdType != .emailAddress,
                  let email = details.email {
            // Otherwise, headline will be the userId. Therefore, we check if the userId is not already
            // displaying the email address. In this case the subheadline will be the email if available.
            return email
        }

        return nil
    }
    
    var body: some View {
        VStack {
            // we gracefully check if the account details have a name, bypassing the subscript overloads
            if let name = details.name {
                UserProfileView(name: name)
                    .frame(height: 90)
            }

            Text(accountHeadline)
                .font(.title2)
                .fontWeight(.semibold)

            if let accountSubheadline = accountSubheadline {
                Text(accountSubheadline)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }


    init(details: AccountDetails) {
        self.details = details
    }
}


#if DEBUG
struct AccountOverviewHeader_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService())

    static var previews: some View {
        AccountOverviewHeader(details: details)
    }
}
#endif
