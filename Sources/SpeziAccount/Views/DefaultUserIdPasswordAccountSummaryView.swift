//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

// TODO this is not userIdPassword specific (and shouldn't be?)
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
    static let details = AccountDetails.Builder()
        .add(\.userId, value: "andi.bauer@tum.de")
        .add(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUsernamePasswordAccountService())

    static var previews: some View {
        DefaultUserIdPasswordAccountSummaryView(account: details)
    }
}
#endif
