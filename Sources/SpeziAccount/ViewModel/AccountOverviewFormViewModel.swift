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


struct ForEachAccountKeyWrapper: Identifiable {
    var id: ObjectIdentifier {
        accountValue.id
    }

    var accountValue: any AccountValueKey.Type

    init(accountValue: any AccountValueKey.Type) {
        self.accountValue = accountValue
    }
}


@MainActor
class AccountOverviewFormViewModel: ObservableObject {
    private static var logger: Logger {
        LoggerKey.defaultValue
    }

    /// We categorize ``AccountValueKey`` by ``AccountValueCategory``. This is completely static and precomputed.
    ///
    /// Instead of iterating over the ``AccountDetails`` and show whatever values are present, we rely on the statically
    /// defined ``AccountValueRequirement``s defined by the user. Using those classifications we can easily allow to model
    /// "shadow" account values that are present but never shown to the user to allow to manage additional state.
    private let categorizedAccountKeys: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]>


    let modifiedDetailsBuilder = ModifiedAccountDetails.Builder() // nested ObservableObject, see init
    let validationClosures = ValidationClosures<String>()

    @Published var presentingCancellationDialog = false
    @Published var presentingLogoutAlert = false
    @Published var presentingRemovalAlert = false

    @Published var addedAccountValues = CategorizedAccountValues()
    @Published var removedAccountValues = CategorizedAccountValues()

    var hasUnsavedChanges: Bool {
        !modifiedDetailsBuilder.isEmpty
    }

    var defaultErrorDescription: LocalizedStringResource {
        .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module))
    }

    private var anyCancellable: AnyCancellable? = nil

    init(account: Account) {
        self.categorizedAccountKeys = account.configuration.reduce(into: [:]) { result, requirement in
            result[requirement.anyKey.category, default: []] += [requirement.anyKey]
        }

        // We forward the objectWillChange publisher. Our `hasUnsavedChanges` is affected by changes to the builder.
        // Otherwise, changes to the object wouldn't be important.
        anyCancellable = modifiedDetailsBuilder.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func accountKeys(by category: AccountValueCategory, using details: AccountDetails) -> [any AccountValueKey.Type] {
        categorizedAccountKeys[category, default: []]
            .sorted(using: AccountOverviewValuesComparator(accountDetails: details, addedAccountValues: addedAccountValues))
    }

    func editableAccountKeys(details accountDetails: AccountDetails) -> OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        let results = categorizedAccountKeys.filter { category, _ in
            category != .credentials && category != .name
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

        resetModelState(editMode: editMode)
    }

    func updateAccountDetails(details: AccountDetails, editMode: Binding<EditMode>? = nil) async throws {
        let removedDetailsBuilder = RemovedAccountDetails.Builder()

        for removedKey in removedAccountValues.values {
            removedKey.addValue(to: removedDetailsBuilder, from: details)
        }

        let modifications = AccountModifications(
            modifiedDetails: modifiedDetailsBuilder.build(),
            removedAccountDetails: removedDetailsBuilder.build()
        )

        try await details.accountService.updateAccountDetails(modifications)
        Self.logger.debug("\(self.modifiedDetailsBuilder.count) items saved successfully.")

        resetModelState(editMode: editMode) // this reset the edit mode as well
    }

    func resetModelState(editMode: Binding<EditMode>? = nil) {
        addedAccountValues = CategorizedAccountValues()
        removedAccountValues = CategorizedAccountValues()

        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear() // it's okay that this doesn't trigger a UI update
        validationClosures.clear()

        editMode?.wrappedValue = .inactive
    }

    func accountIdentifierLabel(details accountDetails: AccountDetails) -> Text {
        let userId = Text(accountDetails.userIdType.localizedStringResource)

        if accountDetails.name != nil {
            return Text(PersonNameKey.name)
                + Text(", ")
                + userId
        }

        return userId
    }

    func accountSecurityLabel(_ configuration: AccountValueConfiguration) -> Text {
        let security = Text("SECURITY", bundle: .module)

        if configuration[PasswordKey.self] != nil {
            return Text("UP_PASSWORD", bundle: .module)
                + Text(" & ")
                + security
        }

        return security
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
