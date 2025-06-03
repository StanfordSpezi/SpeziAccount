//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI


struct PhoneNumbersDetailView: View {
    @State private var viewState = ViewState.idle
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    @Environment(Account.self) private var account
    let phoneNumbers: [String]
    @Binding var phoneNumberViewModel: PhoneNumberViewModel
    
    var body: some View {
        List {
            ForEach(phoneNumbers, id: \.self) { phoneNumber in
                ListRow("Phone") {
                    Text(phoneNumberViewModel.formatPhoneNumberForDisplay(phoneNumber))
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task {
                            do {
                                let accountId = account.details?.accountId ?? ""
                                try await phoneVerificationProvider.deletePhoneNumber(
                                    accountId: accountId,
                                    number: phoneNumber
                                )
                            } catch {
                                viewState = .error(
                                    AnyLocalizedError(
                                        error: error,
                                        defaultErrorDescription: "Failed to delete phone number."
                                    )
                                )
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Phone Numbers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    phoneNumberViewModel.presentSheet = true
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add Phone Number")
                }
            }
        }
        .sheet(isPresented: $phoneNumberViewModel.presentSheet, onDismiss: phoneNumberViewModel.resetState) {
            PhoneNumberSteps()
                .environment(phoneNumberViewModel)
        }
        .viewStateAlert(state: $viewState)
    }
}
    
#Preview {
    NavigationStack {
        PhoneNumbersDetailView(
            phoneNumbers: ["+1 (555) 123-4567", "+1 (555) 987-6543"],
            phoneNumberViewModel: .constant(PhoneNumberViewModel())
        )
    }
}
