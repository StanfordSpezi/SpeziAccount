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


struct PhoneNumberEntryStep: View {
    @State private var viewState = ViewState.idle
    @Environment(\.colorScheme) private var colorScheme
    @Environment(Account.self) private var account
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(PhoneVerificationProvider.self) private var phoneVerificationProvider
    let onNext: () -> Void

   
    var body: some View {
        VStack {
            Spacer()
            PhoneNumberEntryField()
            Text("Enter your phone number and we'll send you a verification code to add the number to your account.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
            AsyncButton(action: {
                do {
                    guard let phoneNumber = phoneNumberViewModel.phoneNumber else {
                        throw AnyLocalizedError(
                            error: NSError(domain: "PhoneNumberVerification", code: 1, userInfo: nil),
                            defaultErrorDescription: "Missing phone number"
                        )
                    }
                    try await phoneVerificationProvider.startVerification(phoneNumber: phoneNumber)
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
                .tint(tintColor)
                .buttonStyleGlassProminent(backup: .borderedProminent)
                .disabled(phoneNumberViewModel.phoneNumber == nil)
                .animation(.default, value: phoneNumberViewModel.phoneNumber == nil)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
    
    private var tintColor: Color {
        guard phoneNumberViewModel.phoneNumber == nil else {
            return Color.accentColor
        }
        
        if colorScheme == .light {
            return Color(.tertiarySystemFill)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
}


#if DEBUG
#Preview {
    PhoneNumberEntryStep(onNext: {})
        .environment(PhoneNumberViewModel())
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), configuration: .default)
            PhoneVerificationProvider()
        }
}
#endif
