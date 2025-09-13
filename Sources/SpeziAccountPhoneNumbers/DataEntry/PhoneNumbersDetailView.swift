//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PhoneNumberKit
import SpeziAccount
import SpeziViews
import SwiftUI


struct PhoneNumbersDetailView: View {
    private enum Event {
        case deletePhoneNumber(PhoneNumber)
    }
    
    @State private var viewState = ViewState.idle
    @State private var events: (stream: AsyncStream<Event>, continuation: AsyncStream<Event>.Continuation) = AsyncStream.makeStream()
    @State private var processingPhoneNumbers: Set<PhoneNumber> = []
    @State private var phoneNumberToDelete: PhoneNumber?
    @Environment(PhoneVerificationProvider.self)
    private var phoneVerificationProvider
    @Environment(Account.self)
    private var account
    @Binding var phoneNumberViewModel: PhoneNumberViewModel

    
    var body: some View {
        // Precompute to help the type-checker
        let phoneNumbers: [PhoneNumber] = account.details?.phoneNumbers ?? []

        List {
            ForEach(phoneNumbers, id: \.self) { phoneNumber in
                row(for: phoneNumber)
            }
        }
            .task {
                await withDiscardingTaskGroup { group in
                    for await event in events.stream {
                        switch event {
                        case let .deletePhoneNumber(phoneNumber):
                            processingPhoneNumbers.insert(phoneNumber)
                            group.addTask { [phoneVerificationProvider] in
                                do {
                                    try await phoneVerificationProvider.deletePhoneNumber(phoneNumber: phoneNumber)
                                } catch {
                                    await MainActor.run {
                                        viewState = .error(
                                            AnyLocalizedError(
                                                error: error,
                                                defaultErrorDescription: "Failed to delete phone number."
                                            )
                                        )
                                    }
                                }
                                _ = await MainActor.run {
                                    processingPhoneNumbers.remove(phoneNumber)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Phone Numbers")
            .navigationBarBackButtonHidden(!processingPhoneNumbers.isEmpty)
#if !os(macOS) && !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar { toolbarContent }
            .sheet(
                isPresented: $phoneNumberViewModel.presentSheet,
                onDismiss: phoneNumberViewModel.resetState
            ) {
                PhoneNumberSteps()
                    .environment(phoneNumberViewModel)
            }
            .alert(
                "Delete Phone Number",
                isPresented: .init(
                    get: { phoneNumberToDelete != nil },
                    set: { if !$0 { phoneNumberToDelete = nil } }
                ),
                actions: { deleteAlertActions() },
                message: { deleteAlertMessage() }
            )
            .overlay { emptyStateOverlay() }
            .viewStateAlert(state: $viewState)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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

    @ViewBuilder
    private func row(for phoneNumber: PhoneNumber) -> some View {
        let isProcessing = processingPhoneNumbers.contains(phoneNumber)
        ListRow(verbatim: phoneNumberViewModel.formatPhoneNumberForDisplay(phoneNumber)) {
            Button(
                action: { phoneNumberToDelete = phoneNumber },
                label: {
                    Image(systemName: "trash.circle.fill")
                        .resizable()
                        .accessibilityLabel("Delete Phone Number")
                        .foregroundStyle(.red)
                        .frame(width: 32, height: 32)
                        .padding(-8)
                }
            )
            .processingOverlay(isProcessing: isProcessing)
            .disabled(isProcessing)
        }
    }

    @ViewBuilder
    private func deleteAlertActions() -> some View {
        if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
            Button(role: .cancel) {
                phoneNumberToDelete = nil
            }
        } else {
            Button("Cancel", role: .cancel) {
                phoneNumberToDelete = nil
            }
        }
        Button("Delete", role: .destructive) {
            if let phoneNumber = phoneNumberToDelete {
                events.continuation.yield(.deletePhoneNumber(phoneNumber))
            }
            phoneNumberToDelete = nil
        }
    }

    @ViewBuilder
    private func deleteAlertMessage() -> some View {
        if let phoneNumber = phoneNumberToDelete {
            Text("Are you sure you want to delete \(phoneNumberViewModel.formatPhoneNumberForDisplay(phoneNumber))?")
        }
    }

    @ViewBuilder
    private func emptyStateOverlay() -> some View {
        if account.details?.phoneNumbers?.isEmpty ?? true {
            ContentUnavailableView {
                Label("No Phone Numbers", systemImage: "phone.badge.plus")
            } description: {
                Text("Added phone numbers will appear here. Add a phone number by tapping the plus (+) button in the top right corner.")
            }
        }
    }
}
    

#if DEBUG
#Preview {
    NavigationStack {
        PhoneNumbersDetailView(phoneNumberViewModel: .constant(PhoneNumberViewModel()))
    }
    .previewWith {
        AccountConfiguration(service: InMemoryAccountService(), configuration: .default)
        PhoneVerificationProvider()
    }
}
#endif
