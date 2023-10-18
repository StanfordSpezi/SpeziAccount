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
class AccountOverviewFormViewModel: ObservableObject {
    private static var logger: Logger {
        LoggerKey.defaultValue
    }

    /// We categorize ``AccountKey`` by ``AccountKeyCategory``. This is completely static and precomputed.
    ///
    /// Instead of iterating over the ``AccountDetails`` and show whatever values are present, we rely on the statically
    /// defined ``AccountKeyRequirement``s defined by the user. Using those classifications we can easily allow to model
    /// "shadow" account keys that are present but never shown to the user to allow to manage additional state.
    private let categorizedAccountKeys: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>


    let modifiedDetailsBuilder = ModifiedAccountDetails.Builder() // nested ObservableObject, see init
    let validationEngines = ValidationEngines<String>()

    @Published var presentingCancellationDialog = false
    @Published var presentingLogoutAlert = false
    @Published var presentingRemovalAlert = false

    @Published var addedAccountKeys = CategorizedAccountKeys()
    @Published var removedAccountKeys = CategorizedAccountKeys()

    var hasUnsavedChanges: Bool {
        !modifiedDetailsBuilder.isEmpty
    }

    var defaultErrorDescription: LocalizedStringResource {
        .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module))
    }

    private var anyCancellable: [AnyCancellable] = []


    init(account: Account) {
        self.categorizedAccountKeys = account.configuration.reduce(into: [:]) { result, configuration in
            result[configuration.key.category, default: []] += [configuration.key]
        }

        // We forward the objectWillChange publisher. Our `hasUnsavedChanges` is affected by changes to the builder.
        // Otherwise, changes to the object wouldn't be important.
        anyCancellable.append(modifiedDetailsBuilder.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        })
        anyCancellable.append(validationEngines.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        })
    }


    func accountKeys(by category: AccountKeyCategory, using details: AccountDetails) -> [any AccountKey.Type] {
        var result = categorizedAccountKeys[category, default: []]
            .sorted(using: AccountOverviewValuesComparator(details: details, added: addedAccountKeys, removed: removedAccountKeys))

        for describedKey in details.accountService.configuration.requiredAccountKeys
            where describedKey.key.category == category {
            result.append(describedKey.key)
        }

        return result
    }

    func editableAccountKeys(details accountDetails: AccountDetails) -> OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        let results = categorizedAccountKeys.filter { category, _ in
            category != .credentials && category != .name
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

        let modifications = AccountModifications(
            modifiedDetails: modifiedDetailsBuilder.build(),
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
            return Text(PersonNameKey.name)
                + Text(", ")
                + userId
        }

        return userId
    }

    func accountSecurityLabel(_ configuration: AccountValueConfiguration, service: any AccountService) -> Text {
        let security = Text("SECURITY", bundle: .module)

        // either password key is required by user configuration or by account service configuration
        let passwordConfigured = configuration[PasswordKey.self] != nil
            || service.configuration.requiredAccountKeys.contains(PasswordKey.self)

        if passwordConfigured {
            return Text("UP_PASSWORD", bundle: .module)
                + Text(" & ")
                + security
        }

        return security
    }


    deinit {
        anyCancellable.forEach { $0.cancel() }
    }
}
