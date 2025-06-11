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


enum FocusPin: Hashable {
    case pin(Int)
}

struct OTCEntryView: View {
    @State private var viewState = ViewState.idle
    @FocusState private var focusState: FocusPin?
    @Environment(Account.self)
    private var account
    @Environment(PhoneVerificationProvider.self)
    private var phoneVerificationProvider
    @Environment(PhoneNumberViewModel.self)
    private var phoneNumberViewModel
    private let codeLength: Int
    @State private var pins: [String]
    @State private var resendTimeOut = 30
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ForEach(0..<codeLength, id: \.self) { index in
                    individualPin(index: index)
                }
            }
                .onChange(of: pins) { _, _ in
                    updateCode()
                }
                .onAppear {
                    focusState = .pin(0)
                }
                .accessibilityElement(children: .combine)
                .accessibilityRepresentation {
                    TextField(String(), text: createAccessibilityBinding())
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Verification code entry")
                        .accessibilityHint("Enter your \(codeLength) digit verification code")
                        .accessibilityValue(pins.joined())
                }
            Spacer()
            resendSection
            Spacer()
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
    
    init(codeLength: Int = 6) {
        precondition(codeLength > 0 && codeLength <= 6, "Code length must be between one and six")
        self.codeLength = codeLength
        self._pins = State(initialValue: Array(repeating: "", count: codeLength))
    }
    
    private func individualPin(index: Int) -> some View {
        TextField(String(), text: $pins[index])
            .modifier(OTCModifier(pin: $pins[index]))
            .accessibilityIdentifier("One-Time Code Entry Pin \(index)")
            .onChange(of: $pins[index].wrappedValue) { _, newValue in
                if !newValue.isEmpty {
                    if index < codeLength - 1 {
                        focusState = .pin(index + 1)
                    }
                }
            }
            .onKeyPress(.delete) {
                if pins[index].isEmpty && index > 0 {
                    pins[index - 1] = ""
                    focusState = .pin(index - 1)
                    return .handled
                }
                return .ignored
            }
            .focused($focusState, equals: .pin(index))
    }
    
    private func updateCode() {
        phoneNumberViewModel.verificationCode = pins.joined()
    }

    private func createAccessibilityBinding() -> Binding<String> {
        Binding(
            get: { pins.joined() },
            set: { newValue in
                let digits = Array(newValue.prefix(codeLength))
                for (index, digit) in digits.enumerated() {
                    pins[index] = String(digit)
                }
                for index in digits.count..<codeLength {
                    pins[index] = ""
                }
                if let nextEmptyIndex = pins.firstIndex(where: { $0.isEmpty }) {
                    focusState = .pin(nextEmptyIndex)
                } else {
                    focusState = .pin(codeLength - 1)
                }
            }
        )
    }
}


#if DEBUG
#Preview {
    OTCEntryView()
}
#endif
