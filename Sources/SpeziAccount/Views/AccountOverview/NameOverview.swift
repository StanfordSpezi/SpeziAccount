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

    @Environment(Account.self)
    private var account


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
                            let name = wrapper.accountKey == AccountKeys.userId
                                ? accountDetails.userIdType.localizedStringResource
                                : wrapper.accountKey.name

                            HStack {
                                Text(name)
                                    .accessibilityHidden(true)
                                Spacer()
                                Text("VALUE_ADD \(name)", bundle: .module)
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
            .navigationTitle(model.accountIdentifierLabel(configuration: account.configuration, accountDetails))
#if !os(macOS) && !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .injectEnvironmentObjects(configuration: accountDetails.accountServiceConfiguration, model: model)
            .environment(\.accountViewType, .overview(mode: .display))
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        AccountDetailsReader { account, details in
            NameOverview(model: AccountOverviewFormViewModel(account: account, details: details), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock())
        }
}

#Preview {
    NavigationStack {
        AccountDetailsReader { account, details in
            NameOverview(model: AccountOverviewFormViewModel(account: account, details: details), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(name: nil))
        }
}
#endif
