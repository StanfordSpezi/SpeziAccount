//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordAccountSummaryView: View {
    private let account: AccountDetails

    @State private var viewState: ViewState = .idle

    // TODO extended summary view (=> edit account info, change email?, remove account)

    public var body: some View {
        VStack {
            UserInformation(name: account.name, caption: account.userId)

            AsyncButton("UP_LOGOUT".localized(.module), role: .destructive, state: $viewState) {
                try await account.accountService.logout()
            }
                .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding()
        }
    }

    public init(account: AccountDetails) {
        self.account = account
    }
}

#if DEBUG
struct DefaultUserIdPasswordAccountSummaryView_Previews: PreviewProvider {
    struct PreviewView: View {
        @EnvironmentObject var account: Account

        var body: some View {
            if let details = account.details {
                DefaultUserIdPasswordAccountSummaryView(account: details)
            }
        }
    }

    static let detailsBuilder = AccountDetails.Builder()
        .add(UserIdAccountValueKey.self, value: "andi.bauer@tum.de")
        .add(NameAccountValueKey.self, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))

    static var previews: some View {
        PreviewView()
            .environmentObject(Account(building: detailsBuilder, active: DefaultUsernamePasswordAccountService()))
    }
}
#endif
