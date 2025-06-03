//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import SwiftUI


/// A view modifier for a cell of a one-time code entry view.
struct OTCModifier: ViewModifier {
    @Binding var pin: String
    var textLimit = 1

    func limitText(_ upper: Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }
    
    
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
#if !os(macOS)
            .keyboardType(.numberPad)
#endif
            .onChange(of: pin) {
                limitText(textLimit)
            }
            .frame(width: 45, height: 45)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.secondary, lineWidth: 1)
            )
    }
}
