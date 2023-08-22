//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct AccountDisplayModel {
    let accountDetails: AccountDetails

    var profileViewName: PersonNameComponents? {
        accountDetails.name
    }

    var accountHeadline: String {
        // we gracefully check if the account details have a name, bypassing the subscript overloads
        if let name = accountDetails.name {
            return name.formatted(.name(style: .long))
        } else {
            // otherwise we display the userId
            return accountDetails.userId
        }
    }

    var accountSubheadline: String? {
        if accountDetails.name != nil {
            // If the accountHeadline uses the name, we display the userId as the subheadline
            return accountDetails.userId
        } else if accountDetails.userIdType != .emailAddress,
                  let email = accountDetails.email {
            // Otherwise, headline will be the userId. Therefore, we check if the userId is not already
            // displaying the email address. In this case the subheadline will be the email if available.
            return email
        }

        return nil
    }

    init(details: AccountDetails) {
        self.accountDetails = details
    }
}
