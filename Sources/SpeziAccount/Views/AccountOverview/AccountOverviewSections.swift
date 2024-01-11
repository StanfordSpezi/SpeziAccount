//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import Spezi
import SpeziValidation
import SpeziViews
import SwiftUI


/// A internal subview of ``AccountOverview`` that expects to be embedded into a `Form`.
@MainActor
struct AccountOverviewSections<AdditionalSections: View>: View {
    let additionalSections: AdditionalSections
    private let accountDetails: AccountDetails
    
    private var service: any AccountService {
        accountDetails.accountService
    }
    
    @Environment(Account.self) private var account

    @Environment(\.logger) private var logger
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: AccountOverviewFormViewModel
    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    // separate view state for any destructive actions like logout or account removal
    @State private var destructiveViewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @Binding private var isEditing: Bool

    var isProcessing: Bool {
        viewState == .processing || destructiveViewState == .processing
    }
    
    
    var body: some View {
        AccountOverviewHeader(details: accountDetails)
            // Every `Section` is basically a `Group` view. So we have to be careful where to place modifiers
            // as they might otherwise be rendered for every element in the Section/Group, e.g., placing multiple buttons.
            .interactiveDismissDisabled(model.hasUnsavedChanges || isProcessing)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false || isProcessing)
            .viewStateAlert(state: $viewState)
            .viewStateAlert(state: $destructiveViewState)
            .toolbar {
                if editMode?.wrappedValue.isEditing == true && !isProcessing {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.cancelEditAction(editMode: editMode)
                        }) {
                            Text("CANCEL", bundle: .module)
                        }
                    }
                }
                if destructiveViewState == .idle {
                    ToolbarItem(placement: .primaryAction) {
                        AsyncButton(state: $viewState, action: editButtonAction) {
                            if editMode?.wrappedValue.isEditing == true {
                                Text("DONE", bundle: .module)
                            } else {
                                Text("EDIT", bundle: .module)
                            }
                        }
                            .disabled(editMode?.wrappedValue.isEditing == true && validation.isDisplayingValidationErrors)
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
                AsyncButton(role: .destructive, state: $destructiveViewState, action: {
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
            .onChange(of: editMode?.wrappedValue.isEditing ?? false) { _, newValue in
                // sync the edit mode with the outer view
                isEditing = newValue
            }
            .anyViewModifier(service.viewStyle.securityRelatedViewModifier) // for delete action

        defaultSections
        
        sectionsView
            .injectEnvironmentObjects(service: service, model: model)
            .receiveValidation(in: $validation)
            .focused($isFocused)
            .animation(nil, value: editMode?.wrappedValue)
        
        additionalSections
        
        Section {
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
    }

    @ViewBuilder private var defaultSections: some View {
        let displayName = model.displaysNameDetails()
        let displaySecurity = model.displaysSignInSecurityDetails(accountDetails)

        if displayName || displaySecurity {
            Section {
                if displayName {
                    NavigationLink {
                        NameOverview(model: model, details: accountDetails)
                    } label: {
                        model.accountIdentifierLabel(configuration: account.configuration, userIdType: accountDetails.userIdType)
                    }
                }

                if displaySecurity {
                    NavigationLink {
                        SecurityOverview(model: model, details: accountDetails)
                    } label: {
                        Text("SIGN_IN_AND_SECURITY", bundle: .module)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var sectionsView: some View {
        ForEach(model.editableAccountKeys(details: accountDetails).elements, id: \.key) { category, accountKeys in
            if !sectionIsEmpty(accountKeys) {
                Section {
                    // the id property of AccountKey.Type is static, so we can't reference it by a KeyPath, therefore the wrapper
                    let forEachWrappers = accountKeys.map { key in
                        ForEachAccountKeyWrapper(key)
                    }
                    
                    ForEach(forEachWrappers, id: \.id) { wrapper in
                        AccountKeyOverviewRow(details: accountDetails, for: wrapper.accountKey, model: model)
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
        details accountDetails: AccountDetails,
        isEditing: Binding<Bool>,
        @ViewBuilder additionalSections: (() -> AdditionalSections) = { EmptyView() }
    ) {
        self.accountDetails = accountDetails
        self._model = State(wrappedValue: AccountOverviewFormViewModel(account: account))
        self._isEditing = isEditing
        self.additionalSections = additionalSections()
    }
    
    
    private func editButtonAction() async throws {
        if editMode?.wrappedValue.isEditing == false {
            editMode?.wrappedValue = .active
            return
        }
        
        guard !model.modifiedDetailsBuilder.isEmpty else {
            logger.debug("Not saving anything, as there were no changes!")
            model.discardChangesAction(editMode: editMode)
            return
        }
        
        guard validation.validateSubviews() else {
            logger.debug("Some input validation failed. Staying in edit mode!")
            return
        }
        
        isFocused = false
        
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
}


#if DEBUG
struct AccountOverviewSections_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)
    
    static var previews: some View {
        NavigationStack {
            AccountOverview {
                Section(header: Text(verbatim: "App")) {
                    NavigationLink {
                        Text(String())
                    } label: {
                        Text(verbatim: "General Settings")
                    }
                    NavigationLink {
                        Text(String())
                    } label: {
                        Text(verbatim: "License Information")
                    }
                }
            }
        }
            .previewWith {
                AccountConfiguration(building: details, active: MockUserIdPasswordAccountService())
            }
    }
}
#endif
