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
            AccountSummaryBox(details: accountDetails)
            Spacer()

            continueButton

            AsyncButton(.init("UP_LOGOUT", bundle: .atURL(from: .module)), role: .destructive, state: $viewState) {
                try await account.accountService.logout()
            }
                .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                .padding(8)
            Spacer()
                .frame(height: 20)
        }
            .padding(.top, 80)
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
    ExistingAccountView(details: .createMock())
        .padding(.horizontal, ViewSizing.outerHorizontalPadding)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    ExistingAccountView(details: .createMock()) {
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
