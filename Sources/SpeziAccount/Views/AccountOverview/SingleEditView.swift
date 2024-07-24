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

    @Environment(Account.self) private var account
    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ValidationState private var validation

    @State private var viewState: ViewState = .idle
    @FocusState private var isFocused: Bool

    private var disabledDone: Bool {
        !model.hasUnsavedChanges // we don't have any changes
            || accountDetails.storage.get(Key.self) == model.modifiedDetailsBuilder.get(Key.self) // it's the same value
            || !validation.allInputValid // or the input isn't valid
    }

    var body: some View {
        Form {
            VStack {
                Key.dataEntryViewWithStoredValueOrInitial(details: accountDetails, for: ModifiedAccountDetails.self)
                    .focused($isFocused)
            }
                .environment(\.accountViewType, .overview(mode: .existing))
                .injectEnvironmentObjects(service: account.accountService, model: model)
        }
            .navigationTitle(Text(Key.self == UserIdKey.self ? accountDetails.userIdType.localizedStringResource : Key.name))
            .viewStateAlert(state: $viewState)
            .receiveValidation(in: $validation)
            .toolbar {
                AsyncButton(state: $viewState, action: submitChange) {
                    Text("DONE", bundle: .module)
                }
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


    private func submitChange() async throws {
        guard validation.validateSubviews() else {
            return
        }

        isFocused = false

        logger.debug("Saving updated \(Key.self) value!")

        try await model.updateAccountDetails(details: accountDetails, using: account)
        dismiss()
    }
}

#if DEBUG
struct SingleEditView_Previews: PreviewProvider {
    static let details: AccountDetails = .build { details in
        details.userId = "lelandstanford@stanford.edu"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    }

    static var previews: some View {
        NavigationStack {
            AccountDetailsReader { account, details in
                SingleEditView<PersonNameKey>(model: AccountOverviewFormViewModel(account: account), details: details)
            }
        }
            .previewWith {
                AccountConfiguration(service: MockAccountService(), activeDetails: details)
            }
    }
}
#endif
