//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PhoneNumberKit
import SpeziValidation
import SpeziViews
import SwiftUI
import Spezi


struct PhoneNumberEntryStep: View {
    @State private var viewState = ViewState.idle
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(Account.self) private var account
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    let onNext: () -> Void
    let phoneNumberUtility: PhoneNumberUtility

   
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Enter your phone number and we'll send you a verification code to add the number to your account.")
                .font(.caption)
                .multilineTextAlignment(.center)
            PhoneNumberEntryField(phoneNumberUtility: phoneNumberUtility)
            Spacer()
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneVerificationProvider.startVerification(data: [
                        "phoneNumber": phoneNumberViewModel.phoneNumber
                    ])
                    onNext()
                } catch {
                    viewState = .error(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to send verification message. Please check your phone number and try again."
                        )
                    )
                }
            }) {
                Text("Send Verification Message")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumberViewModel.phoneNumber.isEmpty)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
}


struct VerificationCodeStep: View {
    @State private var viewState = ViewState.idle
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(Account.self) private var account
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    let codeLength: Int
    let onVerify: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your \(codeLength) digit verification code you received via text message.")
                .font(.caption)
                .multilineTextAlignment(.center)
            OTCEntryView(codeLength: codeLength)
                .keyboardType(.numberPad)
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneVerificationProvider.completeVerification(data: [
                        "phoneNumber": phoneNumberViewModel.phoneNumber,
                        "code": phoneNumberViewModel.verificationCode
                    ])
                    onVerify()
                } catch {
                    viewState = .error(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to verify phone number. Please check your code and try again."
                        )
                    )
                }
            }) {
                Text("Verify Phone Number")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumberViewModel.verificationCode.count < codeLength)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
}


struct PhoneNumbersEntryView: DataEntryView {
    @Environment(\.dismiss) private var dismiss
    @Binding private var phoneNumbers: [String]
    @State private var phoneNumberViewModel = PhoneNumberViewModel()
    @State private var presentSheet = false
    @State private var showDiscardAlert = false
    let phoneNumberUtility = PhoneNumberUtility()
    let codeLength = 6
    var maxPhoneNumbers = 3
    
    private var addingDisabled: Bool {
        phoneNumbers.count >= maxPhoneNumbers
    }
    
    
    var body: some View {
        ForEach($phoneNumbers, id: \.self) { $phoneNumber in
            ListRow("Phone") {
                Text(phoneNumber)
            }
        }
        HStack {
            Spacer()
            Button(action: {
                resetState()
                presentSheet.toggle()
            }, label: {
                Text("Add Phone Number")
            })
                .disabled(addingDisabled)
            }
            .sheet(isPresented: $presentSheet, onDismiss: {
                resetState()
            }, content: {
                NavigationView {
                    phoneEntrySteps
                        .navigationTitle(phoneNumberViewModel.currentStep == .phoneNumber ? "Add Phone Number" : "Enter Verification Code")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    if !phoneNumberViewModel.phoneNumber.isEmpty {
                                        showDiscardAlert = true
                                    } else {
                                        presentSheet = false
                                    }
                                }
                            }
                        }
                }
                    .interactiveDismissDisabled(!phoneNumberViewModel.phoneNumber.isEmpty)
                    .presentationDetents([.medium])
                    .environment(phoneNumberViewModel)
                    
                    .confirmationDialog(
                        "Discard Changes?",
                        isPresented: $showDiscardAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Discard", role: .destructive) {
                            presentSheet = false
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("You have unsaved changes. Are you sure you want to discard them?")
                    }
            })
    }
    
    
    private var phoneEntrySteps: some View {
        Group {
            switch phoneNumberViewModel.currentStep {
            case .phoneNumber:
                PhoneNumberEntryStep(
                    onNext: {
                        phoneNumberViewModel.currentStep = .verificationCode
                    },
                    phoneNumberUtility: phoneNumberUtility
                )
            case .verificationCode:
                VerificationCodeStep(
                    codeLength: codeLength,
                    onVerify: {
                        phoneNumbers.append(phoneNumberViewModel.phoneNumber)
                        presentSheet = false
                    }
                )
            }
        }
    }
    
    init(_ value: Binding<[String]>) {
        self._phoneNumbers = value
    }
    
    init(_ value: Binding<[String]>, maxPhoneNumbers: Int) {
        self._phoneNumbers = value
        self.maxPhoneNumbers = maxPhoneNumbers
    }
    
    private func resetState() {
        phoneNumberViewModel.currentStep = .phoneNumber
        phoneNumberViewModel.phoneNumber = ""
        phoneNumberViewModel.displayedPhoneNumber = ""
        phoneNumberViewModel.verificationCode = ""
    }
}


#if DEBUG
#Preview {
    PhoneNumbersEntryView(.constant([]))
}
#endif
