//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

// TODO this should be non specific to `UserIdPasswordAccountService`; used for simple account services as well!
public struct AccountSummary: View {
    private let account: AccountDetails

    @State private var viewState: ViewState = .idle

    // TODO extended summary view (=> edit account info, change email?, remove account) (maybe split it into an "Overview" view?)

    public var body: some View {
        VStack {
            // TODO don't assume name existence!(?)
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
struct AccountSummary_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUsernamePasswordAccountService())

    static var previews: some View {
        AccountSummary(account: details)
    }
}
#endif
