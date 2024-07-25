//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


/// A simple account summary displayed in the ``AccountSetup`` view when there is already a signed in user account.
public struct AccountSummaryBox: View {
    private let model: AccountDisplayModel

    public var body: some View {
        HStack(spacing: 16) {
            Group {
                if let profileViewName = model.profileViewName {
                    UserProfileView(name: profileViewName)
                        .frame(height: 40)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(.systemGray3))
                        .accessibilityHidden(true)
                }
            }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(model.accountHeadline)
                if let subheadline = model.accountSubheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.background)
                    .shadow(color: .gray, radius: 2)
            )
            .frame(maxWidth: ViewSizing.maxFrameWidth)
            .accessibilityElement(children: .combine)
    }

    /// Create a new `AccountSummaryBox`
    /// - Parameter details: The ``AccountDetails`` to render.
    public init(details: AccountDetails) {
        self.model = AccountDisplayModel(details: details)
    }
}


#if DEBUG
#Preview {
    let emailDetails: AccountDetails = .build { details in
        details.userId = "lelandstanford@stanford.edu"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    }

    return AccountSummaryBox(details: emailDetails)
}

#Preview {
    let usernameDetails: AccountDetails = .build { details in
        details.userId = "leland.stanford"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    }

    return AccountSummaryBox(details: usernameDetails)
}

#Preview {
    let usernameWithoutNameDetails: AccountDetails = .build { details in
        details.userId = "leland.stanford"
    }

    return AccountSummaryBox(details: usernameWithoutNameDetails)
}

#Preview {
    let emailOnlyDetails: AccountDetails = .build { details in
        details.userId = "lelandstanford@stanford.edu"
    }

    return AccountSummaryBox(details: emailOnlyDetails)
}
#endif
