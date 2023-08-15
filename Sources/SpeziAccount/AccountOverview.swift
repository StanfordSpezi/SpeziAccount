//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


public struct AccountOverview: View {
    @EnvironmentObject private var account: Account

    @State private var viewState: ViewState = .idle
    // separate view state for any destructive actions like logout or account removal
    @State private var destructiveViewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountValueKey.Type/focusState`


    public var body: some View {
        if let details = account.details {
            Form {
                // Splitting everything into a separate subview was actually necessary for the EditButton
                // to work in conjunction with the EditMode. Not even the example that Apple provides for the
                // EditMode works. See https://developer.apple.com/forums/thread/716434
                AccountOverviewForm(
                    account: account,
                    details: details,
                    state: $viewState,
                    destructiveState: $destructiveViewState,
                    focusedField: _focusedDataEntry
                )
                    .environment(\.defaultErrorDescription, .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module)))
            }
                .viewStateAlert(state: $viewState)
                .viewStateAlert(state: $destructiveViewState)
                .submitLabel(.done) // TODO next label?
                .toolbar {
                    if destructiveViewState == .idle {
                        ToolbarItemGroup(placement: .primaryAction) {
                            EditButton()
                                .processingOverlay(isProcessing: viewState)
                        }
                    }
                }
                .padding(.top, -20)
                .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
                .navigationBarTitleDisplayMode(.inline)
        } else {
            // TODO handle
            Text("No active Account!")
            // TODO documentation link!
        }
    }

    public init() {}
}


#if DEBUG
struct AccountOverView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static var previews: some View {
        NavigationStack {
            AccountOverview()
                .environmentObject(Account(building: details, active: MockUsernamePasswordAccountService()))
        }
    }
}
#endif
