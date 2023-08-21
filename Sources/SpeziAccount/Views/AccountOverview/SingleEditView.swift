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
    private let accountDetails: AccountDetails

    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var model: AccountOverviewFormViewModel

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    // TODO duplicate! (reconstruct?) just forward?
    private var dataEntryConfiguration: DataEntryConfiguration {
        .init(configuration: accountDetails.accountServiceConfiguration, focusedField: _focusedDataEntry)
    }

    var body: some View {
        Form {
            VStack {
                Key.dataEntryViewWithCurrentStoredValue(details: accountDetails, for: ModifiedAccountDetails.self)
            }
        }
            .navigationTitle(Text(Key.name))
            .environmentObject(dataEntryConfiguration)
            .environmentObject(model.modifiedDetailsBuilder)
            .environmentObject(model.validationClosures) // TODO easily fails?
            .toolbar {
                AsyncButton(state: $viewState, action: submitChange) {
                    Text("DONE", bundle: .module)
                }
                    .disabled(!model.hasUnsavedChanges || accountDetails.storage.get(Key.self) == model.modifiedDetailsBuilder.get(Key.self))
            }
            .onDisappear {
                model.resetModelState()
            }
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }


    private func submitChange() async throws  {
        guard model.validationClosures.validateSubviews(focusState: $focusedDataEntry) else {
            return // TODO does this work here?
        }

        focusedDataEntry = nil

        logger.debug("Saving updated \(Key.self) value!")

        try await model.updateAccountDetails(details: accountDetails)
        dismiss()
    }
}
