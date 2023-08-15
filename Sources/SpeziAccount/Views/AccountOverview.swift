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
    @FocusState private var focusedDataEntry: String? // see `AccountValueKey.Type/focusState`


    public var body: some View {
        if let details = account.details {
            Form {
                // splitting everything into a separate subview was actually necessary for the EditButton
                // to work in conjunction with the EditMode. Not even the example that Apple provides for the
                // EditMode works. See https://developer.apple.com/forums/thread/716434
                AccountOverviewForm(details: details, state: $viewState, focusedField: _focusedDataEntry)
            }
                .viewStateAlert(state: $viewState)
                .submitLabel(.done)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        EditButton()
                            .processingOverlay(isProcessing: viewState)
                    }
                    // TODO warn discarding changes when pressin back button
                    //  => hide back button and place a cancel button!
                }
                .padding(.top, -20)
        } else {
            // TODO handle
            Text("No active Account!")
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
        // TODO .set(\.dateOfBirth, value: Date())

    static var previews: some View {
        NavigationStack {
            AccountOverview()
                .environmentObject(Account(building: details, active: MockUsernamePasswordAccountService()))
                // TODO .environment(\.locale, .init(identifier: "de"))
        }
    }
}
#endif
