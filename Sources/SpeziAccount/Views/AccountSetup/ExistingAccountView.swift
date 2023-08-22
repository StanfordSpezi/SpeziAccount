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

    private var service: any AccountService {
        accountDetails.accountService
    }

    private let continueButton: Continue

    @State private var viewState: ViewState = .idle

    var body: some View {
        VStack {
            VStack {
                AnyView(service.viewStyle.makeAnyAccountSummary(details: accountDetails))

                AsyncButton(.init("UP_LOGOUT", bundle: .atURL(from: .module)), role: .destructive, state: $viewState) {
                    try await service.logout()
                }
                    .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))
                    .padding()
            }
        }
            .viewStateAlert(state: $viewState)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if Continue.self != EmptyView.self {
                        VStack {
                            continueButton
                                .padding()
                            Spacer()
                                .frame(height: 30)
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


extension AccountSetupViewStyle {
    fileprivate func makeAnyAccountSummary(details: AccountDetails) -> AnyView {
        AnyView(self.makeAccountSummary(details: details))
    }
}


#if DEBUG
struct ExistingAccountView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .build(owner: MockUserIdPasswordAccountService())

    static var previews: some View {
        ExistingAccountView(details: details)

        NavigationStack {
            ExistingAccountView(details: details)
        }

        NavigationStack {
            ExistingAccountView(details: details) {
                Button(action: {}, label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: 38)
                })
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
#endif
