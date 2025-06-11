//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SpeziValidation
import SpeziViews
import SwiftUI


struct PhoneNumberSteps: View {
    @Environment(PhoneNumberViewModel.self)
    private var phoneNumberViewModel
    let codeLength: Int
    
    var body: some View {
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
                            if !(phoneNumberViewModel.phoneNumber == nil) {
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
            .interactiveDismissDisabled(!(phoneNumberViewModel.phoneNumber == nil))
            .presentationDetents([.medium])
    }
    
    init(codeLength: Int = 6) {
        self.codeLength = codeLength
    }
}


#if DEBUG
#Preview {
    PhoneNumberSteps()
        .environment(PhoneNumberViewModel())
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), configuration: .default)
            PhoneVerificationProvider()
        }
}
#endif
