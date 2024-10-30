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
            .overlay {
                if account.details == nil {
                    MissingAccountDetailsWarning()
                }
            }
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


/// View and modify the currently associated user account details.
///
/// This provides an overview of the current account details. Further, it allows the user to modify their
/// account values.
///
/// - Important: This view requires to be placed inside a [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack/)
///     to work properly.
///
/// This view requires a currently logged in user (see ``Account/details``).
///
/// Below is a short code example on how to use the `AccountOverview` view.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         NavigationStack {
///             AccountOverview()
///         }
///     }
/// }
/// ```
///
/// Optionally, additional sections can be passed to AccountOverview within the trailing closure, providing the opportunity for customization and extension of the view."
/// Below is a short code example.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         NavigationStack {
///             AccountOverview {
///                 NavigationLink {
///                     // ... next view
///                 } label: {
///                     Text("General Settings")
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// ## Topics
/// ### Configuration
/// - ``CloseBehavior``
/// - ``AccountDeletionBehavior``
/// - ``init(close:deletion:additionalSections:)``
@available(macOS, unavailable)
public struct AccountOverview<AdditionalSections: View>: View {
    /// Defines the behavior for the close button.
    public enum CloseBehavior {
        /// No close button is shown.
        case disabled
        /// A close button is shown that calls the `dismiss` action.
        case showCloseButton
    }

    /// Defines the behavior of delete functionality.
    public enum AccountDeletionBehavior {
        /// Account deletion is not available.
        case disabled
        /// When entering the edit mode, the logout button turns into a delete account button.
        case inEditMode
        /// Show the delete button below the logout button.
        case belowLogout
    }

    private let closeBehavior: CloseBehavior
    private let deletionBehavior: AccountDeletionBehavior
    private let additionalSections: AdditionalSections

    @Environment(Account.self)
    private var account

    @State private var model: AccountOverviewFormViewModel?

    public var body: some View {
        ZStack {
            if let model {
                AccountOverviewForm(model: model, closeBehavior: closeBehavior, deletionBehavior: deletionBehavior) {
                    additionalSections
                }
            }
        }
            .onChange(of: account.signedIn, initial: true) {
                if let details = account.details {
                    if model == nil {
                        model = AccountOverviewFormViewModel(account: account, details: details)
                    }
                } else {
                    model = nil
                }
            }
    }
    
    
    /// Display a new Account Overview.
    /// - Parameters:
    ///   - closeBehavior: Define the behavior of the close button that can be rendered in the toolbar. This is useful when presenting the AccountOverview
    ///     as a sheet. Disabled by default.
    ///   - deletionBehavior: Define how the Account Overview offers the user to delete their account. By default the Logout button turns into a delete button when entering edit mode.
    ///   - additionalSections: Optional additional sections displayed between the other AccountOverview information and the log out button.
    public init(
        close closeBehavior: CloseBehavior = .disabled,
        deletion deletionBehavior: AccountDeletionBehavior = .inEditMode,
        @ViewBuilder additionalSections: () -> AdditionalSections = { EmptyView() }
    ) {
        self.closeBehavior = closeBehavior
        self.deletionBehavior = deletionBehavior
        self.additionalSections = additionalSections()
    }
}


#if DEBUG && !os(macOS)
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return NavigationStack {
        AccountOverview {
            NavigationLink {
                Text(verbatim: "")
                    .navigationTitle(Text(verbatim: "Settings"))
            } label: {
                Text(verbatim: "General Settings")
            }
            NavigationLink {
                Text(verbatim: "")
                    .navigationTitle(Text(verbatim: "Package Dependencies"))
            } label: {
                Text(verbatim: "License Information")
            }
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    NavigationStack {
        AccountOverview()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
