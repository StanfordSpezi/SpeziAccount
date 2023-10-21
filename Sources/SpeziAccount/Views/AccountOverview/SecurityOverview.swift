//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SecurityOverview: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }


    @EnvironmentObject private var account: Account
    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    @State private var presentingPasswordChangeSheet = false


    var body: some View {
        Form {
            // we place every account key of the `.credentials` section except the userId
            let forEachWrappers = model.accountKeys(by: .credentials, using: accountDetails)
                .filter { !$0.isHiddenCredential }
                .map { ForEachAccountKeyWrapper($0) }


            ForEach(forEachWrappers, id: \.id) { wrapper in
                Section {
                    if wrapper.accountKey == PasswordKey.self {
                        // we have a special case for the PasswordKey, as we currently don't expose the capabilities required to the subviews!
                        Button(action: {
                            presentingPasswordChangeSheet = true
                        }) {
                            Text("CHANGE_PASSWORD", bundle: .module)
                        }
                            .sheet(isPresented: $presentingPasswordChangeSheet) {
                                PasswordChangeSheet(model: model, details: accountDetails)
                            }
                    } else {
                        // This view currently doesn't implement an EditMode. Current intention is that the
                        // DataDisplay view of `.credentials` account values just build toggles or NavigationLinks
                        // to manage and change the respective account value.
                        AccountKeyOverviewRow(details: accountDetails, for: wrapper.accountKey, model: model)
                    }
                }
            }
                .injectEnvironmentObjects(service: service, model: model, focusState: $focusedDataEntry)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription)
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle(Text("SIGN_IN_AND_SECURITY", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                model.resetModelState()
            }
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
struct SecurityOverview_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())

    // be aware, modifications won't be displayed due to declaration in PreviewProvider that do not trigger an UI update
    @StateObject static var model = AccountOverviewFormViewModel(account: account)

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                SecurityOverview(model: model, details: details)
            }
        }
            .environmentObject(account)
    }
}
#endif
