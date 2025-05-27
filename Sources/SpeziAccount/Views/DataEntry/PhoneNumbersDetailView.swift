//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct PhoneNumbersDetailView: View {
    @State private var viewState = ViewState.idle
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    @Environment(Account.self) private var account
    let phoneNumbers: [String]
    @State private var phoneNumberViewModel = PhoneNumberViewModel()
    
    var body: some View {
        List {
            ForEach(phoneNumbers, id: \.self) { phoneNumber in
                ListRow("Phone") {
                    Text(phoneNumber)
                }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await phoneVerificationProvider.deletePhoneNumber(accountId: account.details?.accountId ?? "", number: phoneNumber)
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
                        .viewStateAlert(state: $viewState)
                    }
            }
                .navigationTitle("Phone Numbers")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            phoneNumberViewModel.presentSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $phoneNumberViewModel.presentSheet, onDismiss: { phoneNumberViewModel.resetState() }) {
                    NavigationStack {
                        PhoneNumberSteps().environment(phoneNumberViewModel)
                    }
                    .presentationDetents([.medium])
                }
        }
    }
    
    #Preview {
        NavigationStack {
            PhoneNumbersDetailView(phoneNumbers: ["+1 (555) 123-4567", "+1 (555) 987-6543"])
        }
    }
