//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import OrderedCollections
import OSLog
import SpeziViews
import SwiftUI


@MainActor
@Observable
class AccountOverviewFormViewModel {
    private let logger = Logger(subsystem: "edu.stanford.spezi", category: "AccountOverview")

    /// We categorize ``AccountKey`` by ``AccountKeyCategory``. This is completely static and precomputed.
    ///
    /// Instead of iterating over the ``AccountDetails`` and show whatever values are present, we rely on the statically
    /// defined ``AccountKeyRequirement``s defined by the user. Using those classifications we can easily allow to model
    /// "shadow" account keys that are present but never shown to the user to allow to manage additional state.
    private let categorizedAccountKeys: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>
    private let accountServiceConfiguration: AccountServiceConfiguration


    let modifiedDetailsBuilder = AccountDetailsBuilder()

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


    init(_ valueConfiguration: AccountValueConfiguration, _ serviceConfiguration: AccountServiceConfiguration) {
        self.categorizedAccountKeys = valueConfiguration.allCategorizedForDisplay(filteredBy: [.required, .collected, .supported])
        self.accountServiceConfiguration = serviceConfiguration
    }

    convenience init(account: Account, details: AccountDetails) {
        self.init(account.configuration, details.accountServiceConfiguration)
    }

    func accountKeys(by category: AccountKeyCategory, using details: AccountDetails) -> [any AccountKey.Type] {
        var result = categorizedAccountKeys[category, default: []]
            .sorted(using: AccountOverviewValuesComparator(details: details, added: addedAccountKeys, removed: removedAccountKeys))

        for describedKey in accountServiceConfiguration.requiredAccountKeys
            where describedKey.key.category == category {
            if !result.contains(where: { $0 == describedKey.key }) {
                result.append(describedKey.key)
            }
        }

        return result
    }

    private func baseSortedAccountKeys(details accountDetails: AccountDetails) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        var results = categorizedAccountKeys

        for describedKey in accountServiceConfiguration.requiredAccountKeys {
            results[describedKey.key.category, default: []] += [describedKey.key]
        }

        // We want to establish the following order:
        // - account keys where the user has supplied a value
        // - account keys the user just added input in the current edit session
        // - account keys for which the user doesn't have a value (to display a add button at the bottom of a section)
        return results.mapValues { value in
            // sort is stable: see https://github.com/apple/swift-evolution/blob/main/proposals/0372-document-sorting-as-stable.md
            value.sorted(using: AccountOverviewValuesComparator(details: accountDetails, added: addedAccountKeys, removed: removedAccountKeys))
        }
    }
    
    /// The list of account keys that are **potentially** editable.
    /// - Parameter accountDetails: The current account details.
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

        if accountDetails.isAnonymous {
            result.removeValue(forKey: .credentials) // do not allow to add credentials
        } else if result[.credentials]?.contains(where: { $0 == AccountKeys.userId }) == true {
            result[.credentials] = [AccountKeys.userId] // ensure userId is the only credential we display
        }

        return result.reduce(into: []) { result, tuple in
            result.append(contentsOf: tuple.value)
        }
    }

    func addAccountDetail(for value: any AccountKey.Type) {
        guard !addedAccountKeys.contains(value) else {
            return
        }

        logger.debug("Adding new account value \(value) to the edit view!")

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
                modifiedDetailsBuilder.remove(value)
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
    
    @available(macOS, unavailable)
    func cancelEditAction(editMode: Binding<EditMode>?) {
        logger.debug("Pressed the cancel button!")
        if !hasUnsavedChanges {
            discardChangesAction(editMode: editMode)
            return
        }

        presentingCancellationDialog = true

        logger.debug("Found \(self.modifiedDetailsBuilder.count) modified elements. Asking to discard.")
    }

    @available(macOS, unavailable)
    func discardChangesAction(editMode: Binding<EditMode>?) {
        discardChangesAction()

        editMode?.wrappedValue = .inactive
    }

    func discardChangesAction() {
        logger.debug("Exiting edit mode and discarding changes.")

        resetModelState()
    }

    @available(macOS, unavailable)
    func updateAccountDetails(details: AccountDetails, using account: Account, editMode: Binding<EditMode>?) async throws {
        try await updateAccountDetails(details: details, using: account)
        editMode?.wrappedValue = .inactive
    }

    func updateAccountDetails(details: AccountDetails, using account: Account) async throws {
        var removedDetails = AccountDetails()
        removedDetails.add(contentsOf: details, filterFor: removedAccountKeys.keys)

        let modifications = try AccountModifications(
            modifiedDetails: modifiedDetailsBuilder.build(),
            removedAccountDetails: removedDetails
        )

        try await account.accountService.updateAccountDetails(modifications)
        logger.debug("\(self.modifiedDetailsBuilder.count) items saved successfully.")

        resetModelState()
    }

    @available(macOS, unavailable)
    func resetModelState(editMode: Binding<EditMode>?) {
        resetModelState()

        editMode?.wrappedValue = .inactive
    }

    func resetModelState() {
        addedAccountKeys = CategorizedAccountKeys()
        removedAccountKeys = CategorizedAccountKeys()

        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear()
    }

    func accountIdentifierLabel(configuration: AccountValueConfiguration, _ details: AccountDetails) -> Text {
        let userId = Text(details.userIdType.localizedStringResource)

        if configuration.name != nil {
            if details.isAnonymous {
                return Text(AccountKeys.name.name)
            }

            let separator = ", "
            return Text(AccountKeys.name.name)
                + Text(separator)
                + userId
        }

        return userId
    }

    func displaysSignInSecurityDetails(_ details: AccountDetails) -> Bool {
        // We currently do not display the security section for anonymous accounts to avoid them setting a password without supplying an email
        !details.isAnonymous
            && accountKeys(by: .credentials, using: details)
            .contains(where: { !$0.isHiddenCredential })
    }

    func displaysNameDetails(_ details: AccountDetails) -> Bool {
        (categorizedAccountKeys[.credentials]?.contains(where: { $0 == AccountKeys.userId }) == true && !details.isAnonymous)
            || categorizedAccountKeys[.name]?.isEmpty != true
    }
}
