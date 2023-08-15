//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import os
import SpeziViews
import SwiftUI


@MainActor
class AccountOverviewFormViewModel: ObservableObject {
    private static var logger: Logger {
        LoggerKey.defaultValue
    }

    private let account: Account // we just access this for static data


    @Published var presentingCancellationDialog = false
    @Published var presentingLogoutAlert = false
    @Published var presentingRemovalAlert = false

    @Published var addedAccountValues = CategorizedAccountValues()
    @Published var removedAccountValues = CategorizedAccountValues()

    // We are not updating the view based on the properties here. We just need to track these states for processing.
    // As we are using a reference type, state is persisted across views.
    let modifiedDetailsBuilder = ModifiedAccountDetails.Builder()
    let validationClosures = DataEntryValidationClosures()

    var hasUnsavedChanges: Bool {
        !modifiedDetailsBuilder.isEmpty
    }


    init(account: Account) {
        self.account = account
    }


    func accountValuesBySections(details accountDetails: AccountDetails) -> OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        // We could also just iterate over the `AccountDetails` and show whatever is present.
        // However, we deliberately don't do that. We have the `.supported` requirement option for such cases.
        // And not doing this allows for modelling "shadow" account values that are present but never shown to the user
        // to manage additional state.

        let results = account.configuration.reduce(into: OrderedDictionary()) { result, requirement in
            guard requirement.anyKey.category != AccountValueCategory.credentials
                      && requirement.anyKey.id != PersonNameKey.id else {
                // credentials and name categories are handled differently
                return
            }

            result[requirement.anyKey.category, default: []] += [requirement.anyKey]
        }

        // We want to establish the following order:
        // - account values where the user has supplied a value
        // - account values the user just added a filed for input in the current edit session
        // - account values for which the user doesn't have a value (to display a add button at the bottom of a section)
        return results.mapValues { value in
            // sort is stable: see https://github.com/apple/swift-evolution/blob/main/proposals/0372-document-sorting-as-stable.md
            value.sorted(using: AccountOverviewValuesComparator(accountDetails: accountDetails, addedAccountValues: addedAccountValues))
        }
    }

    func addAccountDetail(for value: any AccountValueKey.Type) {
        guard !addedAccountValues.contains(value) else {
            return
        }

        Self.logger.debug("Adding new account value \(value) to the edit view!")

        if let index = removedAccountValues.index(of: value) {
            // This is a account value for which the user has a value set, but which he marked as removed in this session
            // and is now adding back a value for.
            removedAccountValues.remove(at: index, for: value.category)
        } else {
            addedAccountValues.append(value)
        }

        // TODO focusedDataEntry = value.focusState (seems to break everything?)
    }

    func deleteAccountValue(at indexSet: IndexSet, in accountValues: [any AccountValueKey.Type]) {
        for index in indexSet {
            let value = accountValues[index]

            if let addedValueIndex = addedAccountValues.index(of: value) {
                // remove an account value which was just added in the current edit session
                addedAccountValues.remove(at: addedValueIndex, for: value.category)

                // make sure we discard potential changes
                modifiedDetailsBuilder.remove(any: value)
            } else {
                removedAccountValues.append(value)

                // set a empty value to:
                // - have an empty value if it gets added again
                // - the discard button will ask for confirmation
                modifiedDetailsBuilder.setEmptyValue(for: value)
            }
        }
    }

    func cancelEditAction(editMode: Binding<EditMode>?) {
        Self.logger.debug("Pressed the cancel button!")
        if !hasUnsavedChanges {
            discardChangesAction(editMode: editMode)
            return
        }

        presentingCancellationDialog = true

        Self.logger.debug("Found \(self.modifiedDetailsBuilder.count) modified elements. Asking to discard.")
    }

    func discardChangesAction(editMode: Binding<EditMode>?) {
        Self.logger.debug("Exiting edit mode and discarding changes.")

        resetEditState(editMode: editMode)
    }

    func updateAccountDetails(service: any AccountService, details: AccountDetails, editMode: Binding<EditMode>?) async throws {
        let removedDetailsBuilder = RemovedAccountDetails.Builder()

        for removedKey in removedAccountValues.values {
            removedKey.addValue(to: removedDetailsBuilder, from: details)
        }

        let modifications = AccountModifications(
            modifiedDetails: modifiedDetailsBuilder.build(),
            removedAccountDetails: removedDetailsBuilder.build()
        )

        try await service.updateAccountDetails(modifications)
        Self.logger.debug("\(self.modifiedDetailsBuilder.count) items saved successfully.")

        resetEditState(editMode: editMode) // this reset the edit mode as well
    }

    private func resetEditState(editMode: Binding<EditMode>?) {
        addedAccountValues = CategorizedAccountValues()
        removedAccountValues = CategorizedAccountValues()

        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear() // it's okay that this doesn't trigger a UI update
        validationClosures.clear()

        editMode?.wrappedValue = .inactive
    }
}


extension AccountValueKey {
    fileprivate static func addValue<Container: AccountValueStorageContainer>(
        to builder: AccountValueStorageBuilder<Container>,
        from details: AccountDetails
    ) {
        guard let value = details.storage.get(Self.self) else {
            return
        }

        builder.set(Self.self, value: value)
    }
}
