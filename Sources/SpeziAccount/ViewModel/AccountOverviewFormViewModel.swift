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

    private let account: Account
    let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }


    @Published var viewState: Binding<ViewState>
    // we have custom state to control the loading indicator of destructive actions (logout, removal)
    @Published var destructiveViewState: Binding<ViewState>

    @FocusState var focusedDataEntry: String? // TODO this must also be published?
    @Published var presentingCancellationDialog = false
    @Published var presentingLogoutAlert = false
    @Published var presentingRemovalAlert = false

    @Published var addedAccountValues = CategorizedAccountValues()
    @Published var removedAccountValues = CategorizedAccountValues() // TODO communicate them back to the account service!

    // We are not updating the view based on the properties here. We just need to track these states for processing.
    // As we are using a reference type, state is persisted across views.
    var modifiedDetailsBuilder = ModifiedAccountDetails.Builder()
    private var validationClosures = DataEntryValidationClosures()
    var actionTask: Task<Void, Never>?


    var accountValuesBySections: OrderedDictionary<AccountValueCategory, [any AccountValueKey.Type]> {
        // We could also just iterate over the `AccountDetails` and show whatever is present.
        // However, we deliberately don't do that. We have the `.supported` requirement option for such cases.
        // And not doing this allows for modelling "shadow" account values that are present but never shown to the user
        // to manage additional state.

        let results = account.configuration.reduce(into: OrderedDictionary()) { result, requirement in
            guard requirement.anyKey.category != AccountValueCategory.credentials
                    && requirement.anyKey.id != PersonNameKey.id else {
                return
            }
            // TODO we need to handle `Credentials` categories differently!
            //  => assume: UserId will be the only credential that is not about passwords!
            //  => everything else is placed into the `Password & Security` section(?)
            //   => can we do different categories for password and userId?

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

    var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: service.configuration, validationClosures: validationClosures, focusedField: _focusedDataEntry, viewState: viewState)
    }

    var hasUnsavedChanges: Bool {
        !modifiedDetailsBuilder.isEmpty
    }

    var isProcessing: Bool {
        viewState.wrappedValue == .processing || destructiveViewState.wrappedValue == .processing
    }

    var accountHeadline: String {
        // we gracefully check if the account details have a name, bypassing the subscript overloads
        if let name = accountDetails.storage.get(PersonNameKey.self) {
            return name.formatted(.name(style: .long))
        } else {
            // otherwise we display the userId
            return accountDetails.userId
        }
    }

    var accountSubheadline: String? {
        if accountDetails.storage.get(PersonNameKey.self) != nil {
            // If the accountHeadline uses the name, we display the userId as the subheadline
            return accountDetails.userId
        } else if accountDetails.userIdType != .emailAddress,
                  let email = accountDetails.email {
            // Otherwise, headline will be the userId. Therefore, we check if the userId is not already
            // displaying the email address. In this case the subheadline will be the email if available.
            return email
        }

        return nil
    }

    init(
        account: Account,
        details accountDetails: AccountDetails,
        state viewState: Binding<ViewState>,
        destructiveState: Binding<ViewState>,
        focusedField: FocusState<String?>
    ) {
        self.account = account
        self.accountDetails = accountDetails
        self._viewState = Published(wrappedValue: viewState)
        self._destructiveViewState = Published(wrappedValue: destructiveState)
        self._focusedDataEntry = focusedField
    }

    func addAccountDetail(for value: any AccountValueKey.Type) {
        guard !addedAccountValues.contains(value) else {
            return
        }

        // TODO check if it's part of the removed account values? (but set an empty value?)

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
                modifiedDetailsBuilder.remove(any: value) // TODO does this work (preventing the discard confirmation dialog)?
                print(modifiedDetailsBuilder.storage) // TODO remove
            } else {
                removedAccountValues.append(value)

                // set a empty value to:
                // - have an empty value if it gets added again
                // - the discard button will ask for confirmation
                modifiedDetailsBuilder.setEmptyValue(for: value)
                print(modifiedDetailsBuilder.storage) // TODO remove
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

    func onEditModeChange(editMode: Binding<EditMode>?, newValue: EditMode?) async throws {
        if validateInputs() {
            try await service.updateAccountDetails(modifiedDetailsBuilder.build())
            Self.logger.debug("\(self.modifiedDetailsBuilder.count) items saved successfully.")

            resetEditState(editMode: editMode) // this reset the edit mode as well
        } else {
            Self.logger.debug("Some input validation failed. Staying in edit mode!")
        }
    }

    private func validateInputs() -> Bool {
        // TODO this is a 1:1 code copy!
        let failedFields: [String] = validationClosures.compactMap { entry in
            let result = entry.validationClosure()
            switch result {
            case .success:
                return nil
            case .failed:
                return entry.focusStateValue
            case let .failedAtField(focusedField):
                return focusedField
            }
        }

        if let failedField = failedFields.first {
            focusedDataEntry = failedField
            return false
        }

        focusedDataEntry = nil
        return true
    }

    private func resetEditState(editMode: Binding<EditMode>?) {
        // clearing the builder before switching the edit mode
        modifiedDetailsBuilder.clear() // it's okay that this doesn't trigger a UI update
        addedAccountValues = CategorizedAccountValues()

        editMode?.wrappedValue = .inactive
        validationClosures = DataEntryValidationClosures()
    }

    func deleteDisabled(for value: any AccountValueKey.Type) -> Bool {
        if value.isContained(in: accountDetails) && !removedAccountValues.contains(value) {
            return account.configuration[value]?.requirement == .required
        }

        // if not in the addedAccountValues, it's a "add" button
        return !addedAccountValues.contains(value)
    }

    func accountLogoutAction() async throws {
        try? await service.logout()
    }

    func accountRemovalAction() async throws {
        try? await service.delete()
    }
}
