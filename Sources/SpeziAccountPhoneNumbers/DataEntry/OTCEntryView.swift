//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI


struct OTCEntryView: View {
    @State private var viewState = ViewState.idle
    @FocusState private var isTextFieldFocused: Bool
    @Environment(Account.self)
    private var account
    @Environment(PhoneVerificationProvider.self)
    private var phoneVerificationProvider
    @Environment(PhoneNumberViewModel.self)
    private var phoneNumberViewModel
    private let codeLength: Int
    @State private var verificationCode = ""
    @State private var resendTimeOut = 30
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            formattedTextField
                .onAppear {
                    isTextFieldFocused = true
                }
            Spacer()
            resendSection
        }
            .onReceive(timer) { _ in
                if resendTimeOut > 0 {
                    resendTimeOut -= 1
                }
            }
    }


    private var resendSection: some View {
        VStack {
            Text("Didn't receive a verification code?")
                .font(.caption)
                .foregroundStyle(.secondary)
            if resendTimeOut > 0 {
                Text("Please wait for \(resendTimeOut) seconds to resend again.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            AsyncButton(action: {
                do {
                    guard let phoneNumber = phoneNumberViewModel.phoneNumber else {
                        throw AnyLocalizedError(
                            error: NSError(domain: "PhoneNumberVerification", code: 1, userInfo: nil),
                            defaultErrorDescription: "Missing phone number"
                        )
                    }
                    try await phoneVerificationProvider.startVerification(phoneNumber: phoneNumber)
                    resendTimeOut = 30
                } catch {
                    viewState = .error(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to send verification message. Please check your phone number and try again."
                        )
                    )
                }
            }) {
                Text("Resend Verification Message")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .disabled((phoneNumberViewModel.phoneNumber == nil) || resendTimeOut > 0)
            .viewStateAlert(state: $viewState)
        }
    }
    
    private var formattedTextField: some View {
        TextField("", text: $verificationCode)
            .focused($isTextFieldFocused)
            .opacity(0)
            .multilineTextAlignment(.center)
            .frame(width: CGFloat(codeLength) * 60, height: 45)
            .background(
                HStack(spacing: 15) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        pinBackground(index: index)
                    }
                }
            )
            .overlay(
                HStack(spacing: 15) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        pinDigit(index: index)
                    }
                }
            )
            .accessibilityLabel("Verification code entry")
#if !os(macOS)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
#endif
            .onChange(of: verificationCode) { _, newValue in
                let filtered = newValue.filter { $0.isNumber }
                verificationCode = String(filtered.prefix(codeLength))
                updateCode()
            }
    }
    
    init(codeLength: Int = 6) {
        precondition(codeLength > 0 && codeLength <= 6, "Code length must be between one and six")
        self.codeLength = codeLength
    }
    
    private func pinBackground(index: Int) -> some View {
        let isFocused = isTextFieldFocused && index == verificationCode.count
        return RoundedRectangle(cornerRadius: 5)
            .stroke(isFocused ? Color.accentColor : Color.secondary, lineWidth: isFocused ? 2 : 1)
            .frame(width: 45, height: 45)
    }
    
    private func pinDigit(index: Int) -> some View {
        let digit = index < verificationCode.count
            ? String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)])
            : ""
        return Text(digit)
            .font(.body)
            .multilineTextAlignment(.center)
            .frame(width: 45, height: 45)
    }
    
    private func updateCode() {
        phoneNumberViewModel.verificationCode = verificationCode
    }
}


#if DEBUG
#Preview {
    OTCEntryView()
}
#endif
