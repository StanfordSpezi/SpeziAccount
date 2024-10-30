//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziValidation
import SpeziViews
import SwiftUI


@available(macOS, unavailable)
struct AccountOverviewForm<AdditionalSections: View>: View {
    private let model: AccountOverviewFormViewModel
    private let closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior
    private let deletionBehavior: AccountOverview<AdditionalSections>.AccountDeletionBehavior
    private let additionalSections: AdditionalSections

    @Environment(Account.self)
    private var account

    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.editMode)
    private var editMode

    @State private var viewState: ViewState = .idle
    // separate view state for any destructive actions like logout or account removal
    @State private var destructiveViewState: ViewState = .idle

    @ValidationState private var validation
    @FocusState private var isFocused: Bool

    private var isProcessing: Bool {
        viewState == .processing || destructiveViewState == .processing
    }

    var body: some View {
        @Bindable var model = model

        Form {
            if let details = account.details {
                AccountOverviewSections(
                    model: model,
                    details: details,
                    close: closeBehavior,
                    deletion: deletionBehavior,
                    destructiveViewState: $destructiveViewState
                ) {
                    additionalSections
                }
            }
        }
            .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
    #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
    #endif
            .interactiveDismissDisabled(model.hasUnsavedChanges || isProcessing)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false || isProcessing)
            .viewStateAlert(state: $viewState)
            .viewStateAlert(state: $destructiveViewState)
            .receiveValidation(in: $validation)
            .focused($isFocused)
            .toolbar {
                if !isProcessing {
                    ToolbarItem(placement: .cancellationAction) {
                        if editMode?.wrappedValue.isEditing == true {
                            Button(action: {
                                model.cancelEditAction(editMode: editMode)
                            }) {
                                Text("CANCEL", bundle: .module)
                            }
                        } else {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("CLOSE", bundle: .module)
                            }
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
                    do {
                        try await account.accountService.logout()
                    } catch {
                        if error is CancellationError {
                            return
                        }
                        throw error
                    }
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
                    do {
                        try await account.accountService.delete()
                    } catch {
                        if error is CancellationError {
                            return
                        }
                        throw error
                    }
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
            .anyModifiers(account.securityRelatedModifiers.map { $0.anyViewModifier }) // for delete action
    }

    init(
        model: AccountOverviewFormViewModel,
        closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior,
        deletionBehavior: AccountOverview<AdditionalSections>.AccountDeletionBehavior,
        @ViewBuilder additionalSections: () -> AdditionalSections
    ) {
        self.model = model
        self.closeBehavior = closeBehavior
        self.deletionBehavior = deletionBehavior
        self.additionalSections = additionalSections()
    }

    private func editButtonAction() async throws {
        guard let details = account.details else {
            return
        }

        if editMode?.wrappedValue.isEditing == false {
            editMode?.wrappedValue = .active
            return
        }

        guard !model.modifiedDetailsBuilder.isEmpty else {
            account.logger.debug("Not saving anything, as there were no changes!")
            model.discardChangesAction(editMode: editMode)
            return
        }

        guard validation.validateSubviews() else {
            account.logger.debug("Some input validation failed. Staying in edit mode!")
            return
        }

        isFocused = false

        account.logger.debug("Exiting edit mode and saving \(model.modifiedDetailsBuilder.count) changes to AccountService!")

        do {
            try await model.updateAccountDetails(details: details, using: account, editMode: editMode)
        } catch {
            if error is CancellationError {
                return
            }
            throw error
        }
    }
}
