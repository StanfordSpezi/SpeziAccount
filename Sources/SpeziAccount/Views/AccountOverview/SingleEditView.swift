//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SingleEditView<Key: AccountKey>: View {
    private let details: AccountDetails

    private var service: any AccountService {
        details.accountService
    }


    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    var body: some View {
        Form {
            VStack {
                Key.dataEntryViewWithCurrentStoredValue(details: details, for: ModifiedAccountDetails.self)
            }
        }
            .navigationTitle(Text(Key.self == UserIdKey.self ? details.userIdType.localizedStringResource : Key.name))
            .viewStateAlert(state: $viewState)
            .injectEnvironmentObjects(service: service, model: model, focusState: _focusedDataEntry)
            .toolbar {
                AsyncButton(state: $viewState, action: submitChange) {
                    Text("DONE", bundle: .module)
                }
                    .disabled(!model.hasUnsavedChanges || details.storage.get(Key.self) == model.modifiedDetailsBuilder.get(Key.self))
                    .environment(\.defaultErrorDescription, model.defaultErrorDescription)
            }
            .onDisappear {
                model.resetModelState()
            }
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.details = accountDetails
    }


    private func submitChange() async throws {
        guard model.validationClosures.validateSubviews(focusState: $focusedDataEntry) else {
            return // TODO does this work here?
        }

        focusedDataEntry = nil

        logger.debug("Saving updated \(Key.self) value!")

        try await model.updateAccountDetails(details: details)
        dismiss()
    }
}
