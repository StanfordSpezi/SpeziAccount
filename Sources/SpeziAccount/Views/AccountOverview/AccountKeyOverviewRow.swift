//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@available(macOS, unavailable)
struct AccountKeyOverviewRow: View {
    private let accountDetails: AccountDetails
    private let accountKey: any AccountKey.Type
    private let model: AccountOverviewFormViewModel

    @Environment(Account.self)
    private var account
    @Environment(\.editMode)
    private var editMode

    var body: some View {
        if editMode?.wrappedValue.isEditing == true && accountKey.options.contains(.mutable) {
            // we place everything in the same HStack, such that animations are smooth
            let hStack = VStack {
                if accountDetails.contains(accountKey) && !model.removedAccountKeys.contains(accountKey) {
                    Group {
                        if let view = accountKey.dataEntryViewFromBuilder(builder: model.modifiedDetailsBuilder) {
                            view
                        } else {
                            accountKey.dataEntryViewWithStoredValueOrInitial(details: accountDetails)
                        }
                    }
                        .environment(\.accountViewType, .overview(mode: .existing))
                } else if model.addedAccountKeys.contains(accountKey) { // no need to repeat the removedAccountKeys condition
                    accountKey.emptyDataEntryView()
                        .deleteDisabled(false)
                        .environment(\.accountViewType, .overview(mode: .new))
                } else if accountKey.options.contains(.mutable) { // client side mutation allowed
                    Button(action: {
                        model.addAccountDetail(for: accountKey)
                    }) {
                        Text("VALUE_ADD \(accountKey.name)", bundle: .module)
                    }
                }
            }

            // for some reason, SwiftUI doesn't update the view when the `deleteDisabled` changes in our scenario
            if isDeleteDisabled(for: accountKey) {
                hStack
                    .deleteDisabled(true)
            } else {
                hStack
            }
        } else if let view = accountKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails) ?? accountKey.setupView() {
            view
                .deleteDisabled(true) // e.g., prevent deletion of non-mutable account keys
                .disabled(editMode?.wrappedValue.isEditing == true)
                .environment(\.accountViewType, .overview(mode: .display))
        }
    }


    init(details accountDetails: AccountDetails, for accountKey: any AccountKey.Type, model: AccountOverviewFormViewModel) {
        self.accountDetails = accountDetails
        self.accountKey = accountKey
        self.model = model
    }


    @MainActor
    private func isDeleteDisabled(for key: any AccountKey.Type) -> Bool {
        if accountDetails.contains(key) && !model.removedAccountKeys.contains(key) {
            return account.configuration[key]?.requirement == .required
        }

        // if not in the addedAccountKeys, it's a "add" button (which we shouldn't delete)
        return !key.options.contains(.mutable) || !model.addedAccountKeys.contains(key)
    }
}

#if DEBUG && !os(macOS)
private let key = AccountKeys.genderIdentity
#Preview {
    AccountDetailsReader { account, details in
        let model = AccountOverviewFormViewModel(account: account, details: details)

        AccountKeyOverviewRow(details: details, for: key, model: model)
            .injectEnvironmentObjects(configuration: details.accountServiceConfiguration, model: model)
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock(genderIdentity: .male))
        }
}
#endif
