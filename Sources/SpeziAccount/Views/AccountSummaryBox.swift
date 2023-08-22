//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

public struct AccountSummaryBox: View {
    private let model: AccountDisplayModel

    public var body: some View {
        HStack(spacing: 16) {
            if let profileViewName = model.profileViewName {
                UserProfileView(name: profileViewName)
                    .frame(height: 40)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(Color(.systemGray))
            }

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
            .frame(maxWidth: Constants.maxFrameWidth)

        /*
        VStack {
            if let name = account.name {
                // TODO have a fallback for non-name existence!
                UserInformation(name: name, caption: account.userId)
            }


            // TODO move the logout button outwards!
            /
            AsyncButton("UP_LOGOUT".localized(.module), role: .destructive, state: $viewState) {
                try await account.accountService.logout()
            }
                .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding()

        }
             */
    }

    public init(details: AccountDetails) {
        self.model = AccountDisplayModel(details: details)
    }
}

#if DEBUG
struct AccountSummary_Previews: PreviewProvider {
    static let emailDetails = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService())

    static let usernameDetails = AccountDetails.Builder()
        .set(\.userId, value: "andreas.bauer")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService(.username))

    static let usernameWithoutNameDetails = AccountDetails.Builder()
        .set(\.userId, value: "andreas.bauer")
        .build(owner: MockUserIdPasswordAccountService(.username))

    static let emailOnlyDetails = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .build(owner: MockUserIdPasswordAccountService())

    static var previews: some View {
        AccountSummaryBox(details: emailDetails)
        AccountSummaryBox(details: usernameDetails)
        AccountSummaryBox(details: usernameWithoutNameDetails)
        AccountSummaryBox(details: emailOnlyDetails)
    }
}
#endif