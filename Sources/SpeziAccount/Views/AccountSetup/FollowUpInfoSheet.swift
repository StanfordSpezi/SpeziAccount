//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


struct FollowUpInfoSheet: View {
    private let accountDetails: AccountDetails
    private var service: any AccountService {
        accountDetails.accountService
    }

    @Environment(\.logger) private var logger
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var account: Account

    @StateObject private var detailsBuilder = ModifiedAccountDetails.Builder()
    @StateObject private var validationEngines = ValidationEngines<String>()

    @State private var viewState: ViewState = .idle
    @FocusState private var focusedDataEntry: String?

    @State private var presentingCancellationConfirmation = false


    private var accountKeyByCategory: OrderedDictionary<AccountKeyCategory, [any AccountKey.Type]> {
        // TODO maybe just re-categorize the list of keys right?
        account.configuration
            .allCategorized(filteredBy: [.required])
            .mapValues { keys in
                keys.filter { key in
                    !accountDetails.contains(key)
                }
            }
            .filter { category, values in
                // we won't ever ask for credentials again (e.g. password is never present again!)
                category != .credentials && !values.isEmpty
            }
    }

    var body: some View {
        form
            .interactiveDismissDisabled(true)
            .viewStateAlert(state: $viewState)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentingCancellationConfirmation = true
                    }) {
                        Text("CANCEL", bundle: .module)
                    }
                }
            }
            .confirmationDialog(
                Text("CONFIRMATION_DISCARD_ADDITIONAL_INFO_TITLE", bundle: .module),
                isPresented: $presentingCancellationConfirmation,
                titleVisibility: .visible
            ) {
                Button(role: .destructive, action: {
                    dismiss()
                }) {
                    Text("CONFIRMATION_DISCARD_ADDITIONAL_INFO", bundle: .module)
                }
                Button(role: .cancel, action: {}) {
                    Text("CONFIRMATION_KEEP_EDITING", bundle: .module)
                }
            }
    }

    @ViewBuilder private var form: some View {
        Form {
            VStack {
                Image(systemName: "person.crop.rectangle.badge.plus")
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.multicolor)
                    .font(.custom("XXL", size: 50, relativeTo: .title))
                    .accessibilityHidden(true)
                Text("FOLLOW_UP_INFORMATION_TITLE", bundle: .module)
                    .accessibilityAddTraits(.isHeader)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 4)
                Text("FOLLOW_UP_INFORMATION_INSTRUCTIONS", bundle: .module)
                    .padding([.leading, .trailing], 25)
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .padding(.top, -3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            SignupSectionsView(for: ModifiedAccountDetails.self, service: service, sections: accountKeyByCategory)
                .environment(\.accountServiceConfiguration, service.configuration)
                .environment(\.accountViewType, .signup)
                .environmentObject(detailsBuilder)
                .environmentObject(validationEngines)
                .environmentObject(FocusStateObject(focusedField: $focusedDataEntry))

            AsyncButton(state: $viewState, action: completeButtonAction) {
                Text("FOLLOW_UP_INFORMATION_COMPLETE", bundle: .module)
                    .padding(16)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding()
                .padding(-36)
                .listRowBackground(Color.clear)
                .disabled(!validationEngines.allInputValid)
        }
            .environment(\.defaultErrorDescription, .init("ACCOUNT_OVERVIEW_EDIT_DEFAULT_ERROR", bundle: .atURL(from: .module)))
    }


    init(details: AccountDetails) {
        self.accountDetails = details
    }


    private func completeButtonAction() async throws {
        guard validationEngines.validateSubviews(focusState: $focusedDataEntry) else {
            logger.debug("Failed to save updated account information. Validation failed!")
            return
        }

        focusedDataEntry = nil

        let modifiedDetails = detailsBuilder.build() // TODO required verification!
        let removedDetails = RemovedAccountDetails.Builder().build()

        let modifications = AccountModifications(modifiedDetails: modifiedDetails, removedAccountDetails: removedDetails)

        logger.debug("Finished additional account setup. Saving \(detailsBuilder.count) changes!")

        try await service.updateAccountDetails(modifications)

        dismiss()
    }
}


#if DEBUG
struct FollowUpInfoSheet_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "lelandstanford@stanford.edu")

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                FollowUpInfoSheet(details: details)
            }
        }
            .environmentObject(account)
    }
}
#endif
