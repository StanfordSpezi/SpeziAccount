//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountKeyOverviewRow: View {
    private let accountDetails: AccountDetails
    private let accountKey: any AccountKey.Type

    @EnvironmentObject private var account: Account
    @Environment(\.editMode) private var editMode

    @ObservedObject private var model: AccountOverviewFormViewModel

    var body: some View {
        if editMode?.wrappedValue.isEditing == true {
            // we place everything in the same HStack, such that animations are smooth
            let hStack = VStack {
                if accountDetails.contains(accountKey) && !model.removedAccountKeys.contains(accountKey) {
                    Group {
                        if let view = accountKey.dataEntryViewFromBuilder(builder: model.modifiedDetailsBuilder, for: ModifiedAccountDetails.self) {
                            view
                        } else if let view = accountKey.dataEntryViewWithStoredValue(details: accountDetails, for: ModifiedAccountDetails.self) {
                            view
                        }
                    }
                        .environment(\.accountViewType, .overview(mode: .existing))
                } else if model.addedAccountKeys.contains(accountKey) { // no need to repeat the removedAccountKeys condition
                    accountKey.emptyDataEntryView(for: ModifiedAccountDetails.self)
                        .deleteDisabled(false)
                        .environment(\.accountViewType, .overview(mode: .new))
                } else {
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
        } else {
            if let view = accountKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                view
                    .environment(\.accountViewType, .overview(mode: .display))
            }
        }
    }


    init(details accountDetails: AccountDetails, for accountKey: any AccountKey.Type, model: AccountOverviewFormViewModel) {
        self.accountDetails = accountDetails
        self.accountKey = accountKey
        self.model = model
    }


    func isDeleteDisabled(for key: any AccountKey.Type) -> Bool {
        if accountDetails.contains(key) && !model.removedAccountKeys.contains(key) {
            return account.configuration[key]?.requirement == .required
        }

        // if not in the addedAccountKeys, it's a "add" button
        return !model.addedAccountKeys.contains(key)
    }
}

#if DEBUG
struct AccountKeyEditRow_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())

    @StateObject private static var model = AccountOverviewFormViewModel(account: account)
    @FocusState private static var focusedDataEntry: String?

    static var previews: some View {
        if let details = account.details {
            AccountKeyOverviewRow(details: details, for: GenderIdentityKey.self, model: model)
                .injectEnvironmentObjects(service: details.accountService, model: model, focusState: $focusedDataEntry)
        }
    }
}
#endif
