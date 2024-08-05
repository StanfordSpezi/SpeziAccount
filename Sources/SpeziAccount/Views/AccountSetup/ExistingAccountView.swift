//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ExistingAccountView<Continue: View>: View {
    private let accountDetails: AccountDetails
    private let continueButton: Continue

    @Environment(Account.self)
    private var account

    @State private var viewState: ViewState = .idle

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    AccountSummaryBox(details: accountDetails)
                    Spacer()
                        .frame(maxHeight: 180)
                }

                VStack {
                    Spacer()
                    continueButton
                    AsyncButton(.init("UP_LOGOUT", bundle: .atURL(from: .module)), role: .destructive, state: $viewState) {
                        let service = account.accountService
                        try await service.logout()
                    }
                        .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                        .padding(8)
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
            .viewStateAlert(state: $viewState)
    }

    /// Creates a new `ExistingAccountView` to render an already signed in user.
    /// - Parameters:
    ///   - details: The ``AccountDetails`` to render.
    ///   - continue: An optional `Continue` button.
    init(details: AccountDetails, @ViewBuilder `continue`: () -> Continue = { EmptyView() }) {
        self.accountDetails = details
        self.continueButton = `continue`()
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return ExistingAccountView(details: details)
        .padding(.horizontal, ViewSizing.outerHorizontalPadding)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return ExistingAccountView(details: details) {
        Button {
            print("Pressed")
        } label: {
            Text(verbatim: "Continue")
                .frame(maxWidth: .infinity, minHeight: 38)
        }
            .buttonStyle(.borderedProminent)
    }
        .padding(.horizontal, ViewSizing.outerHorizontalPadding)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
