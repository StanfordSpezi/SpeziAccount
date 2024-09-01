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


/// Complete account details with missing information.
///
/// This view can be used to prompt the user to provide additional information that is currently missing from the ``AccountDetails``.
/// By default, SpeziAccount will make sure that the current account is always prompted to provide the required account details should the ``AccountValueConfiguration`` change
/// in the lifetime of the application. Further, depending on the ``FollowUpBehavior`` configuration, the ``AccountSetup`` will automatically present the follow-up information sheet
/// to prompt for missing account details in certain situations.
///
/// However, you can also use this view to design your own flow of requesting additional information. Just pass the account keys to the initializer that should be request from the user.
/// - Note: The requirement level of the account keys is derived from the global ``AccountValueConfiguration``.
@MainActor
public struct FollowUpInfoSheet: View {
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
                        Button(role: .destructive, action: onCancelPressed) {
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


    /// Create a new follow-up information view.
    /// - Parameters:
    ///   - keys: The account keys to ask the user for additional information.
    ///   - cancelBehavior: Defines the behavior when the user attempts to cancel the request for additional information.
    ///   - onComplete: An action that is called once the modification was successful. It provides an overview of all the modifications made.
    public init(
        keys: [any AccountKey.Type],
        cancelBehavior: CancelBehavior = .requireLogout,
        onComplete: @escaping (AccountModifications) -> Void = { _ in }
    ) {
        self.accountKeyByCategory = keys.reduce(into: [:]) { result, key in
            result[key.category, default: []] += [key]
        }
        self.cancelBehavior = cancelBehavior
        self.onComplete = onComplete
    }

    private func onCancelPressed() {
        switch cancelBehavior {
        case .disabled:
            break
        case .requireLogout:
            presentingCancellationConfirmation = true
        case .cancel:
            if detailsBuilder.isEmpty {
                dismiss()
            } else {
                presentingCancellationConfirmation = true
            }
        }
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

        do {
            try await account.accountService.updateAccountDetails(modifications)
        } catch {
            if error is CancellationError {
                return
            }
            throw error
        }

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
