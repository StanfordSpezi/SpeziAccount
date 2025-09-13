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
                    .presentationDetents([.height(250)])
                case .verificationCode:
                    VerificationCodeStep(
                        codeLength: codeLength,
                        onVerify: {
                            phoneNumberViewModel.presentSheet = false
                        }
                    )
                    .presentationDetents([.height(350)])
                }
            }
                .navigationTitle(phoneNumberViewModel.currentStep == .phoneNumber ? "Add Phone Number" : "Enter Verification Code")
#if !os(macOS) && !os(tvOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Group {
                            if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                                Button(role: .cancel) {
                                    cancelAction()
                                }
                            } else {
                                Button("Cancel") {
                                    cancelAction()
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
                }
        }
            .interactiveDismissDisabled(!(phoneNumberViewModel.phoneNumber == nil))
    }
    
    
    init(codeLength: Int = 6) {
        self.codeLength = codeLength
    }
    
    
    private func cancelAction() {
        if !(phoneNumberViewModel.phoneNumber == nil) {
            phoneNumberViewModel.showDiscardAlert = true
        } else {
            phoneNumberViewModel.presentSheet = false
        }
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
