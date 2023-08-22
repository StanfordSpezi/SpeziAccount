//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


/// A internal subview of ``AccountOverview`` that expects to be embedded into a `Form`.
struct AccountOverviewSections: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }

    @EnvironmentObject private var account: Account

    @Environment(\.logger) private var logger
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    // separate view state for any destructive actions like logout or account removal
    @State private var destructiveViewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String? // see `AccountKey.Type/focusState`


    var isProcessing: Bool {
        viewState == .processing || destructiveViewState == .processing
    }


    var body: some View {
        AccountOverviewHeader(details: accountDetails)
            // TODO move them back to the Form!
            // Every `Section` is basically a `Group` view. So we have to be careful where to place modifiers
            // as they might otherwise be rendered for every element in the Section/Group, e.g., placing multiple buttons.
            .interactiveDismissDisabled(model.hasUnsavedChanges || isProcessing)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false || isProcessing)
            .viewStateAlert(state: $viewState)
            .viewStateAlert(state: $destructiveViewState)
            .toolbar {
                if editMode?.wrappedValue.isEditing == true && !isProcessing {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: {
                            model.cancelEditAction(editMode: editMode)
                        }) {
                            Text("CANCEL", bundle: .module)
                        }
                    }
                }
                if destructiveViewState == .idle {
                    ToolbarItemGroup(placement: .primaryAction) {
                        AsyncButton(state: $viewState, action: editButtonAction) {
                            if editMode?.wrappedValue.isEditing == true {
                                Text("DONE", bundle: .module)
                            } else {
                                Text("EDIT", bundle: .module)
                            }
                        }
                            .environment(\.defaultErrorDescription, model.defaultErrorDescription)
                    }
                }
            }
            .confirmationDialog(
                Text("CONFIRMATION_DISCARD_CHANGES_TITLE", bundle: .module),
                isPresented: $model.presentingCancellationDialog,
                titleVisibility: .visible
            ) {
                Button(role: .destructive, action: {
                    model.discardChangesAction(editMode: editMode)
                }) {
                    Text("CONFIRMATION_DISCARD_CHANGES", bundle: .module)
                }
                Button(role: .cancel, action: {}) {
                    Text("CONFIRMATION_KEEP_EDITING", bundle: .module)
                }
            }
            .alert(Text("CONFIRMATION_LOGOUT", bundle: .module), isPresented: $model.presentingLogoutAlert) {
                // Note how the below AsyncButton (in the HStack) uses the same `destructiveViewState`.
                // Due to SwiftUI behavior, the alert will be dismissed immediately. We use the AsyncButton here still
                // to manage our async task and setting the ViewState.
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    try await service.logout()
                }) {
                    Text("UP_LOGOUT", bundle: .module)
                }
                    .environment(\.defaultErrorDescription, .init("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)))

                Button(role: .cancel, action: {}) {
                    Text("CANCEL", bundle: .module)
                }
            }
            .alert(Text("CONFIRMATION_REMOVAL", bundle: .module), isPresented: $model.presentingRemovalAlert) {
                // see the discussion of the AsyncButton in the above alert closure
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    try await service.delete()
                }) {
                    Text("DELETE", bundle: .module)
                }
                    .environment(\.defaultErrorDescription, .init("REMOVE_DEFAULT_ERROR", bundle: .atURL(from: .module)))

                Button(role: .cancel, action: {}) {
                    Text("CANCEL", bundle: .module)
                }
            } message: {
                Text("CONFIRMATION_REMOVAL_SUGGESTION", bundle: .module)
            }

        Section {
            NavigationLink {
                NameOverview(model: model, details: accountDetails)
                    .injectEnvironmentObjects(service: service, model: model, focusState: _focusedDataEntry)
            } label: {
                model.accountIdentifierLabel(details: accountDetails)
            }
            NavigationLink {
                SecurityOverview(model: model, details: accountDetails)
            } label: {
                model.accountSecurityLabel(account.configuration)
            }
        }

        sectionsView
            .injectEnvironmentObjects(service: service, model: model, focusState: _focusedDataEntry)
            .animation(nil, value: editMode?.wrappedValue)

        // TODO think about how the app would react to removed accounts? => app could also allow to skip account setup?
        HStack {
            if editMode?.wrappedValue.isEditing == true {
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    // While the action closure itself is not async, we rely on ability to render loading indicator
                    // of the AsyncButton which based on the externally supplied viewState.
                    model.presentingRemovalAlert = true
                }) {
                    Text("DELETE_ACCOUNT", bundle: .module)
                }
            } else {
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
                    model.presentingLogoutAlert = true
                }) {
                    Text("UP_LOGOUT", bundle: .module)
                }
            }
        }
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder private var sectionsView: some View {
        ForEach(model.editableAccountKeys(details: accountDetails).elements, id: \.key) { category, accountKeys in
            if !sectionIsEmpty(accountKeys) {
                Section {
                    // the id property of AccountKey.Type is static, so we can't reference it by a KeyPath, therefore the wrapper
                    let forEachWrappers = accountKeys.map { key in
                        ForEachAccountKeyWrapper(key)
                    }

                    // TODO seems like the order isn't updated/respected anymore? (case by the loop above?)
                    ForEach(forEachWrappers, id: \.id) { wrapper in
                        buildRow(for: wrapper.accountKey)
                    }
                        .onDelete { indexSet in
                            model.deleteAccountKeys(at: indexSet, in: accountKeys)
                        }
                } header: {
                    if let title = category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
    }


    init(
        account: Account,
        details accountDetails: AccountDetails
    ) {
        self.accountDetails = accountDetails
        self._model = StateObject(wrappedValue: AccountOverviewFormViewModel(account: account))
    }


    @ViewBuilder
    private func buildRow(for accountKey: any AccountKey.Type) -> some View { // TODO move to separate view?
        if editMode?.wrappedValue.isEditing == true {
            // we place everything in the same HStack, such that animations are smooth
            let hStack = HStack {
                if accountDetails.contains(accountKey) && !model.removedAccountKeys.contains(accountKey) {
                    if let view = accountKey.dataEntryViewFromBuilder(builder: model.modifiedDetailsBuilder, for: ModifiedAccountDetails.self) {
                        view
                    } else if let view = accountKey.dataEntryViewWithCurrentStoredValue(details: accountDetails, for: ModifiedAccountDetails.self) {
                        view
                    }
                } else if model.addedAccountKeys.contains(accountKey) { // no need to repeat the removedAccountKeys condition
                    accountKey.emptyDataEntryView(for: ModifiedAccountDetails.self)
                        .deleteDisabled(false)
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
                HStack {
                    view
                }
            }
        }
    }

    private func editButtonAction() async throws {
        if editMode?.wrappedValue.isEditing == false {
            editMode?.wrappedValue = .active
            return
        }

        // TODO move that back into the model again?

        guard !model.modifiedDetailsBuilder.isEmpty else {
            logger.debug("Not saving anything, as there were no changes!")
            model.discardChangesAction(editMode: editMode)
            return
        }

        guard model.validationClosures.validateSubviews(focusState: $focusedDataEntry) else {
            logger.debug("Some input validation failed. Staying in edit mode!")
            return
        }

        focusedDataEntry = nil

        logger.debug("Exiting edit mode and saving \(model.modifiedDetailsBuilder.count) changes to AccountService!")

        try await model.updateAccountDetails(details: accountDetails, editMode: editMode)
    }

    /// Computes if a given `Section` is empty. This is the case if we are **not** currently editing
    /// and the accountDetails don't have values stored for any of the provided ``AccountKey``.
    private func sectionIsEmpty(_ accountKeys: [any AccountKey.Type]) -> Bool {
        guard editMode?.wrappedValue.isEditing == false else {
            // there is always UI presented in EDIT mode
            return false
        }

        // we don't have to check for `addedAccountKeys` as these are only relevant in edit mode
        return accountKeys.allSatisfy { element in
            !accountDetails.contains(element)
        }
    }

    func isDeleteDisabled(for key: any AccountKey.Type) -> Bool {
        if accountDetails.contains(key) && !model.removedAccountKeys.contains(key) {
            return account.configuration[key]?.requirement == .required
        }

        // if not in the addedAccountKeys, it's a "add" button
        return !model.addedAccountKeys.contains(key)
    }
}
