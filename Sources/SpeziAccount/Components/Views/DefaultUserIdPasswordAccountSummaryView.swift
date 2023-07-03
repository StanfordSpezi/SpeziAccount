//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

public struct DefaultUserIdPasswordAccountSummaryView<Service: UserIdPasswordAccountService>: View {
    private let service: Service
    private let account: UserInfo

    @State private var viewState: ViewState = .idle

    public var body: some View {
        VStack {
            UserInformation(name: account.name, caption: account.userId)


            AsyncDataEntrySubmitButton("UP_LOGOUT".localized(.module), role: .destructive, state: $viewState) {
                try await service.logout()
            }
            .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            .padding()
        }
    }

    public init(using service: Service, account: UserInfo) {
        self.service = service
        self.account = account
    }
}

struct DefaultUserIdPasswordAccountSummaryView_Previews: PreviewProvider {
    static let account1: UserInfo = AccountValueStorageBuilder()
        .add(UserIdAccountValueKey.self, value: "andi.bauer@tum.de")
        .add(NameAccountValueKey.self, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build()

    static var previews: some View {
        DefaultUserIdPasswordAccountSummaryView(using: DefaultUsernamePasswordAccountService(), account: account1)
    }
}
