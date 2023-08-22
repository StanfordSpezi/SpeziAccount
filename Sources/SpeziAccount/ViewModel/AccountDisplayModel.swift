//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct AccountDisplayModel {
    let details: AccountDetails

    var profileViewName: PersonNameComponents? {
        details.name
    }

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

    init(details: AccountDetails) {
        self.details = details
    }
}
