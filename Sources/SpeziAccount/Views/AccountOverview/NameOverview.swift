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

    var body: some View { // TODO only render this view if any of the two is present!
        Form {
            Section {
                // TODO check if that is supported?
                NavigationLink {
                    SingleEditView<UserIdKey>(model: model, details: accountDetails)
                } label: {
                    UserIdKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails)
                }
            }

            // TODO only if person name is supported right?
            Section {
                NavigationLink {
                    SingleEditView<PersonNameKey>(model: model, details: accountDetails)
                } label: {
                    if let name = accountDetails.name {
                        PersonNameKey.DataDisplay(name)
                    } else {
                        HStack {
                            Text(PersonNameKey.name)
                                .accessibilityHidden(true)
                            Spacer()
                            Text("VALUE_ADD \(PersonNameKey.name)", bundle: .module)
                                .foregroundColor(.secondary)
                        }
                            .accessibilityElement(children: .combine)
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

    static let detailsWithoutName = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())
    static let accountWithoutName = Account(building: detailsWithoutName, active: MockUserIdPasswordAccountService())

    // be aware, modifications won't be displayed due to declaration in PreviewProvider that do not trigger an UI update
    @StateObject static var model = AccountOverviewFormViewModel(account: account)

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                NameOverview(model: model, details: details)
            }
        }
            .environmentObject(account)

        NavigationStack {
            if let details = accountWithoutName.details {
                NameOverview(model: model, details: details)
            }
        }
        .environmentObject(accountWithoutName)
    }
}
#endif
