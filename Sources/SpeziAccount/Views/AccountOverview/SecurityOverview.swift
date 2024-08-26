//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziViews
import SwiftUI


@available(macOS, unavailable)
struct SecurityOverview: View {
    private let accountDetails: AccountDetails


    @Environment(Account.self)
    private var account
    @Environment(AccountOverviewFormViewModel.self)
    private var model

    @State private var viewState: ViewState = .idle


    var body: some View {
        Form {
            // we place every account key of the `.credentials` section except the userId
            let forEachWrappers = model.accountKeys(by: .credentials, using: accountDetails)
                .filter { !$0.isHiddenCredential }
                .map { ForEachAccountKeyWrapper($0) }


            ForEach(forEachWrappers, id: \.id) { wrapper in
                Section {
                    Text("Collect \(wrapper)")
                    // This view currently doesn't implement an EditMode. Current intention is that the
                    // DataDisplay view of `.credentials` account values just build toggles or NavigationLinks
                    // to manage and change the respective account value.
                    AccountKeyOverviewRow(details: accountDetails, for: wrapper.accountKey)
                }
            }
                .injectEnvironmentObjects(configuration: accountDetails.accountServiceConfiguration, model: model)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription)
        }
            .viewStateAlert(state: $viewState)
            .navigationTitle(Text("SIGN_IN_AND_SECURITY", bundle: .module))
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .onDisappear {
                model.resetModelState()
            }
    }


    init(details accountDetails: AccountDetails) {
        self.accountDetails = accountDetails
    }
}


#if DEBUG && !os(macOS)
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return NavigationStack {
        AccountDetailsReader { account, details in
            SecurityOverview(details: details)
                .environment(AccountOverviewFormViewModel(account: account, details: details))
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
