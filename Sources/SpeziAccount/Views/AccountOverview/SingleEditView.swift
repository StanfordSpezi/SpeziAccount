//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziValidation
import SpeziViews
import SwiftUI


@MainActor
struct SingleEditView<Key: AccountKey>: View {
    private let model: AccountOverviewFormViewModel
    private let accountDetails: AccountDetails

    @Environment(Account.self)
    private var account
    @Environment(\.dismiss)
    private var dismiss

    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    private var disabledDone: Bool {
        !model.hasUnsavedChanges // we don't have any changes
            || accountDetails[Key.self] == model.modifiedDetailsBuilder.get(Key.self) // it's the same value
            || !validation.allInputValid // or the input isn't valid
    }

    var body: some View {
        Form {
            VStack {
                Key.dataEntryViewWithStoredValueOrInitial(details: accountDetails)
                    .focused($isFocused)
            }
                .environment(\.accountViewType, .overview(mode: .existing))
                .injectEnvironmentObjects(configuration: accountDetails.accountServiceConfiguration, model: model)
        }
            .navigationTitle(Text(Key.self == AccountKeys.userId ? accountDetails.userIdType.localizedStringResource : Key.name))
            .viewStateAlert(state: $viewState)
            .receiveValidation(in: $validation)
            .toolbar {
                AsyncButton(state: $viewState, action: submitChange) {
                    if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                        Image(systemName: "checkmark")
                            .accessibilityLabel("Done")
                    } else {
                        Text("Done", bundle: .module)
                    }
                }
                    .buttonStyleGlassProminent()
                    .disabled(disabledDone)
                    .environment(\.defaultErrorDescription, model.defaultErrorDescription)
            }
            .onDisappear {
                model.resetModelState()
            }
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }

    init(for keyPath: KeyPath<AccountKeys, Key.Type>, model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.init(model: model, details: accountDetails)
    }


    private func submitChange() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        account.logger.debug("Saving updated \(Key.self) value!")

        do {
            try await model.updateAccountDetails(details: accountDetails, using: account)
        } catch {
            if error is CancellationError {
                return
            }
            throw error
        }
        dismiss()
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AccountDetailsReader { account, details in
            SingleEditView(for: \.name, model: AccountOverviewFormViewModel(account: account, details: details), details: details)
        }
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: .createMock())
        }
}
#endif
