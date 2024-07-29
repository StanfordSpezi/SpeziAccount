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
    private let model: AccountOverviewFormViewModel
    private let accountDetails: AccountDetails

    @Environment(Account.self) private var account


    var body: some View {
        Form {
            let forEachWrappers = model.namesOverviewKeys(details: accountDetails)
                .map { ForEachAccountKeyWrapper($0) }

            ForEach(forEachWrappers, id: \.id) { wrapper in
                Section {
                    NavigationLink {
                        wrapper.accountKey.singleEditView(model: model, details: accountDetails)
                            .anyModifiers(account.securityRelatedModifiers.map { $0.anyViewModifier })
                    } label: {
                        if let view = wrapper.accountKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                            view
                        } else {
                            HStack {
                                Text(wrapper.accountKey.name)
                                    .accessibilityHidden(true)
                                Spacer()
                                Text("VALUE_ADD \(wrapper.accountKey.name)", bundle: .module)
                                    .foregroundColor(.secondary)
                            }
                                .accessibilityElement(children: .combine)
                        }
                    }
                } header: {
                    if wrapper.accountKey == AccountKeys.name,
                       let title = AccountKeys.name.category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
            .navigationTitle(model.accountIdentifierLabel(configuration: account.configuration, userIdType: accountDetails.userIdType))
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .injectEnvironmentObjects(service: account.accountService, model: model)
            .environment(\.accountViewType, .overview(mode: .display))
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return NavigationStack {
        AccountDetailsReader { account, details in
            NameOverview(model: AccountOverviewFormViewModel(account: account), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: MockAccountService(), activeDetails: details)
        }
}

#Preview {
    var detailsWithoutName = AccountDetails()
    detailsWithoutName.userId = "lelandstanford@stanford.edu"

    return NavigationStack {
        AccountDetailsReader { account, details in
            NameOverview(model: AccountOverviewFormViewModel(account: account), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: MockAccountService(), activeDetails: detailsWithoutName)
        }
}
#endif
