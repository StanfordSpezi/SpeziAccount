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
@available(watchOS, unavailable)
struct AccountOverviewForm<AdditionalSections: View>: View {
    private let model: AccountOverviewFormViewModel
    private let closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior
    private let logoutBehavior: AccountOverview<AdditionalSections>.AccountLogoutBehavior
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
                    logout: logoutBehavior,
                    deletion: deletionBehavior,
                    destructiveViewState: destructiveViewState,
                    additionalSections: additionalSections
                )
            }
        }
            .navigationTitle(Text("ACCOUNT_OVERVIEW", bundle: .module))
    #if !os(macOS) && !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
    #endif
            .interactiveDismissDisabled(model.hasUnsavedChanges || isProcessing)
            .navigationBarBackButtonHidden(editMode?.wrappedValue.isEditing ?? false || isProcessing)
            .viewStateAlert(state: $viewState)
            .viewStateAlert(state: $destructiveViewState)
            .receiveValidation(in: $validation)
            .focused($isFocused)
            .toolbar {
                toolbar
            }
            .accountOperationAlert(
                isPresented: $model.presentingLogoutAlert,
                operation: logoutBehavior,
                viewState: $destructiveViewState,
                defaultErrorDescription: LocalizedStringResource("UP_LOGOUT_FAILED_DEFAULT_ERROR", bundle: .atURL(from: .module)),
                dismiss: dismiss,
                defaultOperation: { try await account.accountService.logout() }
            )
            .accountOperationAlert(
                isPresented: $model.presentingRemovalAlert,
                operation: deletionBehavior,
                viewState: $destructiveViewState,
                defaultErrorDescription: LocalizedStringResource("REMOVE_DEFAULT_ERROR", bundle: .atURL(from: .module)),
                dismiss: dismiss,
                defaultOperation: { try await account.accountService.delete() }
            )
            .anyModifiers(account.securityRelatedModifiers.map { $0.anyViewModifier }) // for delete action
    }
    
    @ViewBuilder
    private var cancellationButton: some View {
        if editMode?.wrappedValue.isEditing == true {
            if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                Button(role: .cancel) {
                    model.cancelEditAction(editMode: editMode)
                }
            } else {
                Button {
                    model.cancelEditAction(editMode: editMode)
                } label: {
                    Text("Cancel", bundle: .module)
                }
            }
        } else {
            switch closeBehavior {
            case .disabled:
                EmptyView()
            case .showCloseButton:
                if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                    Button(role: .close) {
                        dismiss()
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close", bundle: .module)
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        @Bindable var model = model
        
        if !isProcessing {
            ToolbarItem(placement: .cancellationAction) {
                cancellationButton
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
            }
        }

        if destructiveViewState == .idle {
            ToolbarItem(placement: .primaryAction) {
                AsyncButton(state: $viewState, action: editButtonAction) {
                    if editMode?.wrappedValue.isEditing == true {
                        if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                            Image(systemName: "checkmark")
                                .accessibilityLabel("Done")
                        } else {
                            Text("Done", bundle: .module)
                        }
                    } else {
                        Text("Edit", bundle: .module)
                    }
                }
                .if(editMode?.wrappedValue.isEditing == true) { $0.buttonStyleGlassProminent() }
                .disabled(editMode?.wrappedValue.isEditing == true && validation.isDisplayingValidationErrors)
                .environment(\.defaultErrorDescription, model.defaultErrorDescription)
            }
        }
    }

    init(
        model: AccountOverviewFormViewModel,
        closeBehavior: AccountOverview<AdditionalSections>.CloseBehavior,
        logoutBehavior: AccountOverview<AdditionalSections>.AccountLogoutBehavior,
        deletionBehavior: AccountOverview<AdditionalSections>.AccountDeletionBehavior,
        additionalSections: AdditionalSections
    ) {
        self.model = model
        self.closeBehavior = closeBehavior
        self.logoutBehavior = logoutBehavior
        self.deletionBehavior = deletionBehavior
        self.additionalSections = additionalSections
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


extension View {
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @ViewBuilder
    fileprivate func accountOperationAlert( // swiftlint:disable:this function_parameter_count
        isPresented: Binding<Bool>,
        operation: some AccountOverviewDestructiveAccountOperation,
        viewState: Binding<ViewState>,
        defaultErrorDescription: LocalizedStringResource?,
        dismiss: DismissAction,
        defaultOperation: @MainActor @escaping () async throws -> Void
    ) -> some View {
        let labels = operation.labels
        if let handler = operation.handler {
            self.alert(Text(labels.confirmationAlertTitle), isPresented: isPresented) {
                // Note how the below AsyncButton (in the HStack) uses the same `destructiveViewState`.
                // Due to SwiftUI behavior, the alert will be dismissed immediately. We use the AsyncButton here still
                // to manage our async task and setting the ViewState.
                AsyncButton(role: .destructive, state: viewState) {
                    do {
                        switch handler {
                        case .default:
                            try await defaultOperation()
                        case .custom(labels: _, let handler):
                            try await handler()
                        }
                    } catch {
                        if error is CancellationError {
                            return
                        }
                        throw error
                    }
                    dismiss()
                } label: {
                    Text(labels.confirmationAlertSubmitButton)
                }
                .environment(\.defaultErrorDescription, defaultErrorDescription)
                
                Button(role: .cancel, action: {}) {
                    Text(labels.confirmationAlertCancelButton)
                }
            } message: {
                if let message = labels.confirmationAlertMessage {
                    Text(message)
                }
            }
        } else {
            self
        }
    }
}
