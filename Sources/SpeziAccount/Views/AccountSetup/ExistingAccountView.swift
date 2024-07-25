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
    private let continueButton: Continue

    @Environment(Account.self) private var account

    @State private var viewState: ViewState = .idle

    var body: some View {
        VStack {
            VStack {
                AccountSummaryBox(details: accountDetails)

                AsyncButton(.init("UP_LOGOUT", bundle: .atURL(from: .module)), role: .destructive, state: $viewState) {
                    let service = account.accountService
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
#Preview {
    ExistingAccountView(details: AccountDetails.build { details in
        details.userId = "lelandstanford@stanford.edu"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    })
}

#Preview {
    NavigationStack {
        ExistingAccountView(details: AccountDetails.build { details in
            details.userId = "lelandstanford@stanford.edu"
            details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
        }) {
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
