//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import OrderedCollections
import os
import SpeziViews
import SwiftUI


@MainActor
@Observable
class AccountOverviewFormViewModel {
    private static var logger: Logger {
        LoggerKey.defaultValue
    }

    /// We categorize ``AccountKey`` by ``AccountKeyCategory``. This is completely static and precomputed.
    ///
    /// Instead of iterating over the ``AccountDetails`` and show whatever values are present, we rely on the statically
    /// defined ``AccountKeyRequirement``s defined by the user. Using those classifications we can easily allow to model
    /// "shadow" account keys that are present but never shown to the user to allow to manage additional state.
    private let categorizedAccountKeys: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>


    let modifiedDetailsBuilder = ModifiedAccountDetails.Builder()

    var presentingCancellationDialog = false
    var presentingLogoutAlert = false
    var presentingRemovalAlert = false

    var addedAccountKeys = CategorizedAccountKeys()
    var removedAccountKeys = CategorizedAccountKeys()

    var hasUnsavedChanges: Bool {
        !modifiedDetailsBuilder.isEmpty
    }

    var defaultErrorDescription: LocalizedStringResource {
        .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module))
    }


    init(account: Account) {
        self.categorizedAccountKeys = account.configuration.allCategorized()
    }


    func accountKeys(by category: AccountKeyCategory, using details: AccountDetails) -> [any AccountKey.Type] {
        var result = categorizedAccountKeys[category, default: []]
            .sorted(using: AccountOverviewValuesComparator(details: details, added: addedAccountKeys, removed: removedAccountKeys))

        for describedKey in details.accountService.configuration.requiredAccountKeys
            where describedKey.key.category == category {
            if !result.contains(where: { $0 == describedKey.key }) {
                result.append(describedKey.key)
            }
        }

        return result
    }

    private func baseSortedAccountKeys(details accountDetails: AccountDetails) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        var results = categorizedAccountKeys

        for describedKey in accountDetails.accountService.configuration.requiredAccountKeys {
            results[describedKey.key.category, default: []] += [describedKey.key]
        }

        // We want to establish the following order:
        // - account keys where the user has supplied a value
        // - account keys the user just added a filed for input in the current edit session
        // - account keys for which the user doesn't have a value (to display a add button at the bottom of a section)
        return results.mapValues { value in
            // sort is stable: see https://github.com/apple/swift-evolution/blob/main/proposals/0372-document-sorting-as-stable.md
            value.sorted(using: AccountOverviewValuesComparator(details: accountDetails, added: addedAccountKeys, removed: removedAccountKeys))
        }
    }

    func editableAccountKeys(details accountDetails: AccountDetails) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        baseSortedAccountKeys(details: accountDetails).filter { category, _ in
            category != .credentials && category != .name
        }
    }

    func namesOverviewKeys(details accountDetails: AccountDetails) -> [any AccountKey.Type] {
        var result = baseSortedAccountKeys(details: accountDetails)
            .filter { category, _ in
                category == .credentials || category == .name
            }

        if result[.credentials]?.contains(where: { $0 == UserIdKey.self }) == true {
            result[.credentials] = [UserIdKey.self] // ensure userId is the only credential we display
        }

        return result.reduce(into: []) { result, tuple in
            result.append(contentsOf: tuple.value)
        }
    }

    func addAccountDetail(for value: any AccountKey.Type) {
        guard !addedAccountKeys.contains(value) else {
            return
        }

        Self.logger.debug("Adding new account value \(value) to the edit view!")

        if let index = removedAccountKeys.index(of: value) {
            // This is a account value for which the user has a value set, but which he marked as removed in this session
            // and is now adding back a value for.
            removedAccountKeys.remove(at: index, for: value.category)
        } else {
            addedAccountKeys.append(value)
        }
    }

    func deleteAccountKeys(at indexSet: IndexSet, in accountKeys: [any AccountKey.Type]) {
        for index in indexSet {
            let value = accountKeys[index]

            if let addedValueIndex = addedAccountKeys.index(of: value) {
                // remove an account value which was just added in the current edit session
                addedAccountKeys.remove(at: addedValueIndex, for: value.category)

                // make sure we discard potential changes
                modifiedDetailsBuilder.remove(any: value)
            } else {
                // a removed account key that is still present in the current account details
                removedAccountKeys.append(value)

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

        resetModelState(editMode: editMode)
    }

    func updateAccountDetails(details: AccountDetails, editMode: Binding<EditMode>? = nil) async throws {
        let removedDetailsBuilder = RemovedAccountDetails.Builder()
        removedDetailsBuilder.merging(with: removedAccountKeys.keys, from: details)

        let modifications = try AccountModifications(
            modifiedDetails: modifiedDetailsBuilder.build(validation: true),
            removedAccountDetails: removedDetailsBuilder.build()
        )

        try await details.accountService.updateAccountDetails(modifications)
        Self.logger.debug("\(self.modifiedDetailsBuilder.count) items saved successfully.")

        resetModelState(editMode: editMode) // this reset the edit mode as well
    }

    func resetModelState(editMode: Binding<EditMode>? = nil) {
        addedAccountKeys = CategorizedAccountKeys()
        removedAccountKeys = CategorizedAccountKeys()

        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear() // it's okay that this doesn't trigger a UI update

        editMode?.wrappedValue = .inactive
    }

    func accountIdentifierLabel(configuration: AccountValueConfiguration, userIdType: UserIdType) -> Text {
        let userId = Text(userIdType.localizedStringResource)

        if configuration[PersonNameKey.self] != nil {
            let separator = ", "
            return Text(PersonNameKey.name)
                + Text(separator)
                + userId
        }

        return userId
    }

    func displaysSignInSecurityDetails(_ details: AccountDetails) -> Bool {
        accountKeys(by: .credentials, using: details)
            .contains(where: { !$0.isHiddenCredential })
    }

    func displaysNameDetails() -> Bool {
        categorizedAccountKeys[.credentials]?.contains(where: { $0 == UserIdKey.self }) == true
            || categorizedAccountKeys[.name]?.isEmpty != true
    }
}
