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


struct FollowUpInfoFormHeader: View {
    var body: some View {
        FormHeader(
            image: Image(systemName: "person.crop.rectangle.badge.plus"), // swiftlint:disable:this accessibility_label_for_image
            title: Text("FOLLOW_UP_INFORMATION_TITLE", bundle: .module),
            instructions: Text("FOLLOW_UP_INFORMATION_INSTRUCTIONS", bundle: .module)
        )
    }

    init() {}
}


/// A 
@MainActor
public struct FollowUpInfoSheet: View { // TODO: docs!
    /// Defines the behavior of the cancel button for the followup-info sheet.
    public enum CancelBehavior {
        /// Cancel button is not shown.
        case disabled
        /// Cancellation results in logout.
        case requireLogout
        /// Cancellation dismisses the view.
        case cancel
    }

    private let accountKeyByCategory: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]>
    private let cancelBehavior: CancelBehavior
    private let onComplete: (AccountModifications) -> Void


    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(Account.self)
    private var account

    @State private var detailsBuilder = AccountDetailsBuilder()
    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    @State private var presentingCancellationConfirmation = false


    public var body: some View {
        form
            .interactiveDismissDisabled(true)
            .receiveValidation(in: $validation)
            .viewStateAlert(state: $viewState)
            .toolbar {
                if cancelBehavior != .disabled {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .destructive) {
                            presentingCancellationConfirmation = true
                        } label: {
                            Text("CANCEL", bundle: .module)
                        }
                    }
                }
            }
            .confirmationDialog(
                cancelBehavior.confirmationMessage,
                isPresented: $presentingCancellationConfirmation,
                titleVisibility: .visible
            ) {
                AsyncButton(role: cancelBehavior.actionRole, state: $viewState) {
                    try await account.accountService.logout()
                    dismiss()
                } label: {
                    cancelBehavior.actionLabel
                }

                Button(role: .cancel, action: {}) {
                    Text("CONFIRMATION_KEEP_EDITING", bundle: .module)
                }
            }
    }

    @ViewBuilder private var form: some View {
        Form {
            FollowUpInfoFormHeader()
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .padding(.top, -3)

            SignupSectionsView(sections: accountKeyByCategory)
                .environment(\.accountServiceConfiguration, account.accountService.configuration)
                .environment(\.accountViewType, .signup)
                .environment(detailsBuilder)
                .focused($isFocused)

            AsyncButton(state: $viewState, action: completeButtonAction) {
                Text("FOLLOW_UP_INFORMATION_COMPLETE", bundle: .module)
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                .disabled(!validation.allInputValid)
        }
            .environment(\.defaultErrorDescription, .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }


    public init(
        keys: [any AccountKey.Type],
        cancelBehavior: CancelBehavior = .requireLogout,
        onComplete: @escaping (AccountModifications) -> Void = { _ in }
    ) { // TODO: docs
        self.accountKeyByCategory = keys.reduce(into: [:]) { result, key in
            result[key.category, default: []] += [key]
        }
        self.cancelBehavior = cancelBehavior
        self.onComplete = onComplete
    }


    private func completeButtonAction() async throws {
        guard validation.validateSubviews() else {
            account.logger.debug("Failed to save updated account information. Validation failed!")
            return
        }

        isFocused = false

        let modifiedDetails = detailsBuilder.build()

        let modifications = try AccountModifications(modifiedDetails: modifiedDetails)

        account.logger.debug("Finished additional account setup. Saving \(detailsBuilder.count) changes!")

        let service = account.accountService
        try await service.updateAccountDetails(modifications)

        onComplete(modifications)

        dismiss()
    }
}


extension FollowUpInfoSheet.CancelBehavior {
    var confirmationMessage: Text {
        switch self {
        case .requireLogout:
            Text("CONFIRMATION_DISCARD_ADDITIONAL_INFO_TITLE", bundle: .module)
        case .cancel:
            Text("CONFIRMATION_DISCARD_CHANGES_TITLE", bundle: .module)
        case .disabled:
            Text(verbatim: "")
        }
    }

    var actionRole: ButtonRole? {
        switch self {
        case .requireLogout:
            .destructive
        default:
            nil
        }
    }

    var actionLabel: Text {
        switch self {
        case .requireLogout:
            Text("UP_LOGOUT", bundle: .module)
        default:
            Text("CANCEL", bundle: .module)
        }
    }
}


#if DEBUG
private let keys: [any AccountKey.Type] = [AccountKeys.name]
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"

    return NavigationStack {
        FollowUpInfoSheet(keys: keys)
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
