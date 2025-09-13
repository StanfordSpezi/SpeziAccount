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


struct VerificationCodeStep: View {
    @State private var viewState = ViewState.idle
    @Environment(\.colorScheme) private var colorScheme
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(Account.self) private var account
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    
    let codeLength: Int
    let onVerify: () -> Void
    
    
    var body: some View {
        VStack(spacing: 20) {
            OTCEntryView(codeLength: codeLength)
#if !os(macOS)
                .keyboardType(.numberPad)
#endif
            AsyncButton(action: {
                do {
                    guard let phoneNumber = phoneNumberViewModel.phoneNumber else {
                        throw AnyLocalizedError(
                            error: NSError(domain: "PhoneNumberVerification", code: 1, userInfo: nil),
                            defaultErrorDescription: "Missing phone number"
                        )
                    }
                    try await phoneVerificationProvider.completeVerification(phoneNumber: phoneNumber, code: phoneNumberViewModel.verificationCode)
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
                .tint(.accentColor)
                .buttonStyleGlassProminent(backup: .borderedProminent)
                .disabled(phoneNumberViewModel.verificationCode.count < codeLength)
                .animation(.default, value: phoneNumberViewModel.phoneNumber == nil)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
}


#if DEBUG
#Preview {
    VerificationCodeStep(codeLength: 6, onVerify: {})
        .environment(PhoneNumberViewModel())
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), configuration: .default)
            PhoneVerificationProvider()
        }
}
#endif
