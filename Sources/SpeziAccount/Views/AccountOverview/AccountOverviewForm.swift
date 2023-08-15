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
struct AccountOverviewForm: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }

    @EnvironmentObject private var account: Account

    @Environment(\.logger) private var logger
    @Environment(\.defaultErrorDescription) private var defaultErrorDescription
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: AccountOverviewFormViewModel


    var body: some View {
        AccountOverviewHeader(details: accountDetails)
            // Every `Section` is basically a `Group` view. So we have to be careful where to place modifiers
            // as they might otherwise be rendered for every element in the Section/Group, e.g., placing multiple buttons.
            .interactiveDismissDisabled(model.hasUnsavedChanges || model.isProcessing)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false || model.isProcessing)
            .onChange(of: editMode?.wrappedValue, perform: onEditModeChange)
            .toolbar {
                if editMode?.wrappedValue.isEditing == true && !model.isProcessing {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: {
                            model.cancelEditAction(editMode: editMode)
                        }) {
                            Text("CANCEL", bundle: .module)
                        }
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
                AsyncButton(role: .destructive, state: model.destructiveViewState, action: {
                    try await service.logout()
                    dismiss()
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
                AsyncButton(role: .destructive, state: model.destructiveViewState, action: {
                    try await service.delete()
                    dismiss()
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
                    .environmentObject(model.dataEntryConfiguration(service: service))
                    .environmentObject(model.modifiedDetailsBuilder)
            } label: {
                HStack(spacing: 0) {
                    if accountDetails.storage.get(PersonNameKey.self) != nil {
                        Text("NAME", bundle: .module)
                        Text(verbatim: ", ")
                    }
                    Text(accountDetails.userIdType.localizedStringResource)
                }
            }
            NavigationLink {
                SecurityOverview(model: model, details: accountDetails)
                    .environmentObject(model.dataEntryConfiguration(service: service))
                    .environmentObject(model.modifiedDetailsBuilder)
            } label: {
                HStack(spacing: 0) {
                    if account.configuration[PasswordKey.self] != nil {
                        Text("UP_PASSWORD", bundle: .module)
                        Text(" & ")
                    }
                    Text("SECURITY", bundle: .module)
                }
            }
        }

        sectionsView
            .environmentObject(model.dataEntryConfiguration(service: service))
            .environmentObject(model.modifiedDetailsBuilder)
            .animation(nil, value: editMode?.wrappedValue)

            // TODO think about how the app would react to removed accounts? => app could also allow to skip account setup?
            HStack {
                if editMode?.wrappedValue.isEditing == true {
                    AsyncButton(role: .destructive, state: model.destructiveViewState, action: {
                        // While the action closure itself is not async, we rely on ability to render loading indicator
                        // of the AsyncButton which based on the externally supplied viewState.
                        model.presentingRemovalAlert = true
                    }) {
                        Text("DELETE_ACCOUNT", bundle: .module)
                    }
                } else {
                    AsyncButton(role: .destructive, state: model.destructiveViewState, action: {
                        model.presentingLogoutAlert = true
                    }) {
                        Text("UP_LOGOUT", bundle: .module)
                    }
                }
            }
                .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder private var sectionsView: some View {
        ForEach(model.accountValuesBySections(details: accountDetails).elements, id: \.key) { category, accountValues in
            if !sectionIsEmpty(accountValues) {
                Section {
                    // While the stored values in `AccountDetails` can change, the list of displayed
                    // account values (the AccountValueConfiguration) does not change! So index based access is okay here.
                    ForEach(accountValues.indices, id: \.self) { index in
                        buildRow(for: accountValues[index])
                    }
                        .onDelete { indexSet in
                            model.deleteAccountValue(at: indexSet, in: accountValues)
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
        details accountDetails: AccountDetails,
        state viewState: Binding<ViewState>,
        destructiveState: Binding<ViewState>,
        focusedField: FocusState<String?>
    ) {
        self.accountDetails = accountDetails
        self._model = StateObject(wrappedValue: AccountOverviewFormViewModel(
            account: account,
            state: viewState,
            destructiveState: destructiveState,
            focusedField: focusedField
        ))
    }


    @ViewBuilder
    private func buildRow(for accountValue: any AccountValueKey.Type) -> some View { // TODO move to separate view?
        if editMode?.wrappedValue.isEditing == true {
            // we place everything in the same HStack, such that animations are smooth
            let hStack = HStack {
                if accountValue.isContained(in: accountDetails) && !model.removedAccountValues.contains(accountValue) {
                    if let view = accountValue.dataEntryViewFromBuilder(builder: model.modifiedDetailsBuilder, for: ModifiedAccountDetails.self) {
                        view
                    } else if let view = accountValue.dataEntryViewWithCurrentStoredValue(details: accountDetails, for: ModifiedAccountDetails.self) {
                        view
                    }
                } else if model.addedAccountValues.contains(accountValue) { // no need to repeat the removedAccountValues condition
                    accountValue.emptyDataEntryView(for: ModifiedAccountDetails.self)
                        .deleteDisabled(false)
                } else {
                    Button(action: {
                        model.addAccountDetail(for: accountValue)
                    }) {
                        Text("VALUE_ADD \(accountValue.name)", bundle: .module)
                    }
                }
            }

            // for some reason, SwiftUI doesn't update the view when the `deleteDisabled` changes
            if isDeleteDisabled(for: accountValue) {
                hStack
                    .deleteDisabled(true)
            } else {
                hStack
            }
        } else {
            if let view = accountValue.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                HStack {
                    view
                }
            }
        }
    }

    private func onEditModeChange(newValue: EditMode?) {
        guard newValue == .inactive,
              model.viewState.wrappedValue != .processing else {
            return
        }

        guard !model.modifiedDetailsBuilder.isEmpty else {
            logger.debug("Not saving anything, as there were no changes!")
            return
        }

        logger.debug("Exiting edit mode and saving \(model.modifiedDetailsBuilder.count) changes to AccountService!")

        withAnimation(.easeOut(duration: 0.2)) {
            model.viewState.wrappedValue = .processing
        }

        model.actionTask = Task {
            do {
                // TODO do all the visual debounce like AsyncButton?
                try await model.onEditModeChange(service: service, editMode: editMode, newValue: newValue)

                withAnimation(.easeIn(duration: 0.2)) {
                    model.viewState.wrappedValue = .idle
                }
            } catch {
                model.viewState.wrappedValue = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: defaultErrorDescription
                ))
            }
        }
    }

    /// Computes if a given `Section` is empty. This is the case if we are **not** currently editing
    /// and the accountDetails don't have values stored for any of the provided ``AccountValueKey``.
    private func sectionIsEmpty(_ accountValues: [any AccountValueKey.Type]) -> Bool {
        guard editMode?.wrappedValue.isEditing == false else {
            // there is always UI presented in EDIT mode
            return false
        }

        // we don't have to check for `addedAccountValues` as these are only relevant in edit mode
        return accountValues.allSatisfy { element in
            !element.isContained(in: accountDetails)
        }
    }

    func isDeleteDisabled(for value: any AccountValueKey.Type) -> Bool {
        if value.isContained(in: accountDetails) && !model.removedAccountValues.contains(value) {
            return account.configuration[value]?.requirement == .required
        }

        // if not in the addedAccountValues, it's a "add" button
        return !model.addedAccountValues.contains(value)
    }
}
