//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI


struct SingleEditView<Key: AccountKey>: View {
    private let accountDetails: AccountDetails

    private var service: any AccountService {
        accountDetails.accountService
    }


    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var model: AccountOverviewFormViewModel
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
                .injectEnvironmentObjects(service: service, model: model)
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

        try await model.updateAccountDetails(details: accountDetails)
        dismiss()
    }
}

#if DEBUG
struct SingleEditView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())

    // be aware, modifications won't be displayed due to declaration in PreviewProvider that do not trigger an UI update
    @StateObject static var model = AccountOverviewFormViewModel(account: account)

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                SingleEditView<PersonNameKey>(model: model, details: details)
            }
        }
            .environment(account)
    }
}
#endif
