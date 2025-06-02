//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziValidation
import SpeziViews
import SwiftUI


struct PhoneNumberSteps: View {
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    let codeLength: Int
    
    public var body: some View {
        @Bindable var phoneNumberViewModel = phoneNumberViewModel
        // swiftlint:disable:next closure_body_length
        NavigationStack {
            Group {
                switch phoneNumberViewModel.currentStep {
                case .phoneNumber:
                    PhoneNumberEntryStep(
                        onNext: {
                            phoneNumberViewModel.currentStep = .verificationCode
                        }
                    )
                case .verificationCode:
                    VerificationCodeStep(
                        codeLength: codeLength,
                        onVerify: {
                            phoneNumberViewModel.presentSheet = false
                        }
                    )
                }
            }
                .navigationTitle(phoneNumberViewModel.currentStep == .phoneNumber ? "Add Phone Number" : "Enter Verification Code")
#if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            if !phoneNumberViewModel.phoneNumber.isEmpty {
                                phoneNumberViewModel.showDiscardAlert = true
                            } else {
                                phoneNumberViewModel.presentSheet = false
                            }
                        }
                    }
                }
                .confirmationDialog(
                    "Discard Changes?",
                    isPresented: $phoneNumberViewModel.showDiscardAlert,
                    titleVisibility: .visible
                ) {
                    Button("Discard", role: .destructive) {
                        phoneNumberViewModel.presentSheet = false
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("You have unsaved changes. Are you sure you want to discard them?")
                }
        }
            .interactiveDismissDisabled(!phoneNumberViewModel.phoneNumber.isEmpty)
            .presentationDetents([.medium])
    }
    
    public init(codeLength: Int = 6) {
        self.codeLength = codeLength
    }
}


struct PhoneNumberEntryStep: View {
    @State private var viewState = ViewState.idle
    @Environment(Account.self) private var account
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    let onNext: () -> Void

   
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Enter your phone number and we'll send you a verification code to add the number to your account.")
                .font(.caption)
                .multilineTextAlignment(.center)
            PhoneNumberEntryField()
            Spacer()
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneVerificationProvider.startVerification(
                        accountId: account.details?.accountId ?? "",
                        data: [
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
#if !os(macOS)
                .keyboardType(.numberPad)
#endif
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneVerificationProvider.completeVerification(
                        accountId: account.details?.accountId ?? "",
                        data: [
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
