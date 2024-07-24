//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


// TODO: redesign this view, maybe just the a continue closure and primary/secondary button design?
struct ExistingAccountView<Continue: View>: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }

    private let continueButton: Continue

    @State private var viewState: ViewState = .idle

    var body: some View {
        VStack {
            VStack {
                AccountSummaryBox(details: accountDetails) // TODO: how to keep that customizable?

                AsyncButton(.init("UP_LOGOUT", bundle: .atURL(from: .module)), role: .destructive, state: $viewState) {
                    try await service.logout()
                }
                    .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                    .padding()
            }
        }
            .viewStateAlert(state: $viewState)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if Continue.self != EmptyView.self {
                        VStack {
                            continueButton
                                .padding(.horizontal)
                            Spacer()
                                .frame(height: 20)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
    }

    /// Creates a new `ExistingAccountView` to render an already signed in user.
    ///
    /// - Note: When using a non empty `Continue` button, this view must be placed within a `NavigationStack`
    ///     in order to render the toolbar.
    /// - Parameters:
    ///   - details: The ``AccountDetails`` to render.
    ///   - continue: An optional `Continue` button.
    init(details: AccountDetails, @ViewBuilder `continue`: () -> Continue = { EmptyView() }) {
        self.accountDetails = details
        self.continueButton = `continue`()
    }
}


#if DEBUG
@MainActor private let details = AccountDetails.Builder()
    .set(\.userId, value: "andi.bauer@tum.de")
    .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
    .build(owner: MockAccountService())

#Preview {
    ExistingAccountView(details: details)
}

#Preview {
    NavigationStack {
        ExistingAccountView(details: details) {
            Button {
                print("Pressed")
            } label: {
                Text(verbatim: "Continue")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
#endif
