//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum FocusPin: Hashable {
    case pin(Int)
}

struct OTCEntryView: View {
    @FocusState private var focusState: FocusPin?
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    private let codeLength: Int
    @State private var pins: [String]
    
    
    var body: some View {
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
    }
    
    init(codeLength: Int = 6) {
        precondition(codeLength > 0 && codeLength <= 6, "Code length must be between one and six")
        self.codeLength = codeLength
        self._pins = State(initialValue: Array(repeating: "", count: codeLength))
    }
    
    private func individualPin(index: Int) -> some View {
        TextField("", text: $pins[index])
            .modifier(OTCModifier(pin: $pins[index]))
            .accessibilityIdentifier("pin-\(index)")
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
}


#if DEBUG
#Preview {
    OTCEntryView()
}
#endif
