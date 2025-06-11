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
    private enum Event {
        case deletePhoneNumber(String)
    }
    
    @State private var viewState = ViewState.idle
    @State private var events: (stream: AsyncStream<Event>, continuation: AsyncStream<Event>.Continuation) = AsyncStream.makeStream()
    @State private var processingPhoneNumbers: Set<String> = []
    @State private var phoneNumberToDelete: String?
    @Environment(PhoneVerificationProvider.self)
    private var phoneVerificationProvider
    @Environment(Account.self)
    private var account
    let phoneNumbers: [String]
    @Binding var phoneNumberViewModel: PhoneNumberViewModel

    
    var body: some View {
        List {
            ForEach(phoneNumbers, id: \.self) { phoneNumber in
                ListRow("Phone") {
                    HStack {
                        Text(verbatim: phoneNumberViewModel.formatPhoneNumberForDisplay(phoneNumber))
                        Button("Remove", role: .destructive) {
                            phoneNumberToDelete = phoneNumber
                        }
                        .processingOverlay(isProcessing: processingPhoneNumbers.contains(phoneNumber))
                    }
                }
            }
        }
            .task {
                for await event in events.stream {
                    switch event {
                    case let .deletePhoneNumber(phoneNumber):
                        processingPhoneNumbers.insert(phoneNumber)
                        do {
                            let phoneNumber = try phoneNumberViewModel.phoneNumberUtility.parse(phoneNumber)
                            try await phoneVerificationProvider.deletePhoneNumber(phoneNumber: phoneNumber)
                        } catch {
                            viewState = .error(
                                AnyLocalizedError(
                                    error: error,
                                    defaultErrorDescription: "Failed to delete phone number."
                                )
                            )
                        }
                        processingPhoneNumbers.remove(phoneNumber)
                    }
                }
            }
            .navigationTitle("Phone Numbers")
            .navigationBarBackButtonHidden(!processingPhoneNumbers.isEmpty)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        phoneNumberViewModel.presentSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add Phone Number")
                    }
                        .disabled(!processingPhoneNumbers.isEmpty)
                }
            }
            .sheet(isPresented: $phoneNumberViewModel.presentSheet, onDismiss: phoneNumberViewModel.resetState) {
                PhoneNumberSteps()
                    .environment(phoneNumberViewModel)
            }
            .alert("Delete Phone Number", isPresented: .init(
                get: { phoneNumberToDelete != nil },
                set: { if !$0 { phoneNumberToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    phoneNumberToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let phoneNumber = phoneNumberToDelete {
                        events.continuation.yield(.deletePhoneNumber(phoneNumber))
                    }
                    phoneNumberToDelete = nil
                }
            } message: {
                if let phoneNumber = phoneNumberToDelete {
                    Text("Are you sure you want to delete \(phoneNumberViewModel.formatPhoneNumberForDisplay(phoneNumber))?")
                }
            }
            .overlay {
                if phoneNumbers.isEmpty {
                    ContentUnavailableView {
                        Label("No Phone Numbers", systemImage: "phone.badge.plus")
                    } description: {
                        Text("Added phone numbers will appear here. Add a phone number by tapping the plus (+) button in the top right corner.")
                    }
                }
            }
            .viewStateAlert(state: $viewState)
    }
}
    

#if DEBUG
#Preview {
    NavigationStack {
        PhoneNumbersDetailView(
            phoneNumbers: ["+1 (555) 123-4567", "+1 (555) 987-6543"],
            phoneNumberViewModel: .constant(PhoneNumberViewModel())
        )
    }
    .previewWith {
        AccountConfiguration(service: InMemoryAccountService(), configuration: .default)
        PhoneVerificationProvider()
    }
}
#endif
