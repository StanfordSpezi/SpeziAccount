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
            Button("Change Password", action: {
                presentingPasswordChangeSheet = true
            })
                .sheet(isPresented: $presentingPasswordChangeSheet) {
                    PasswordChangeSheet(model: model, details: accountDetails)
                }

            // we place every account key of the `.credentials` section except the userId and password below
            let forEachWrappers = model.accountKeys(by: .credentials, using: accountDetails)
                .filter { $0 != UserIdKey.self && $0 != PasswordKey.self }
                .map { ForEachAccountKeyWrapper($0) }


            ForEach(forEachWrappers, id: \.id) { wrapper in
                Section {
                    // This view currently doesn't implement an EditMode. Current intention is that the
                    // DataDisplay view of `.credentials` account values just build toggles or NavigationLinks
                    // to manage and change the respective account value.
                    AccountKeyEditRow(details: accountDetails, for: wrapper.accountKey, model: model)
                }
            }
                .injectEnvironmentObjects(service: service, model: model, focusState: _focusedDataEntry)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription)
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle(model.accountSecurityLabel(account.configuration))
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
    static var previews: some View {
        Text("Hello") // TODO can we provide a preview?
    }
}
#endif
