//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NameOverview: View {
    private let accountDetails: AccountDetails

    @EnvironmentObject private var account: Account

    @ObservedObject private var model: AccountOverviewFormViewModel

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    SingleEditView<UserIdKey>(model: model, details: accountDetails)
                } label: {
                    HStack {
                        UserIdKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails)
                    }
                }
            }

            Section {
                NavigationLink {
                    SingleEditView<PersonNameKey>(model: model, details: accountDetails)
                } label: {
                    HStack {
                        if let name = accountDetails.name {
                            PersonNameKey.DataDisplay(name)
                        } else {
                            Text(PersonNameKey.name)
                            Spacer()
                            Text("VALUE_ADD \(PersonNameKey.name)", bundle: .module)
                        }
                    }
                }
            } header: {
                if let title = PersonNameKey.category.categoryTitle {
                    Text(title)
                }
            }
        }
            .navigationTitle(model.accountIdentifierLabel(configuration: account.configuration, userIdType: accountDetails.userIdType))
            .navigationBarTitleDisplayMode(.inline)
            .injectEnvironmentObjects(service: accountDetails.accountService, model: model)
            .environment(\.accountViewType, .overview(mode: .display))
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
struct NameOverview_Previews: PreviewProvider {
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
                NameOverview(model: model, details: details)
            }
        }
            .environmentObject(account)
    }
}
#endif
