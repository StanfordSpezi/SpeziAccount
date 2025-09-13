//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    package func buttonStyleGlass() -> some View {
        buttonStyleGlass(buttonStyle: PlainButtonStyle.self)
    }
    
    package func buttonStyleGlass<B: PrimitiveButtonStyle>(backup: B) -> some View {
        buttonStyleGlass(backup: backup, buttonStyle: B.self)
    }
    
    @ViewBuilder
    private func buttonStyleGlass<B: PrimitiveButtonStyle>(backup: B? = nil, buttonStyle: B.Type = B.self) -> some View {
        #if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26, macOS 26, macCatalyst 26, tvOS 26, watchOS 26, *) {
            self.buttonStyle(.glass)
        } else if let backup {
            self.buttonStyle(backup)
        } else {
            self
        }
        #else
        if let backup {
            self.buttonStyle(backup)
        } else {
            self
        }
        #endif
    }
    
    package func buttonStyleGlassProminent() -> some View {
        buttonStyleGlassProminent(buttonStyle: PlainButtonStyle.self)
    }
    
    package func buttonStyleGlassProminent<B: PrimitiveButtonStyle>(backup: B) -> some View {
        buttonStyleGlassProminent(backup: backup, buttonStyle: B.self)
    }
    
    @ViewBuilder
    private func buttonStyleGlassProminent<B: PrimitiveButtonStyle>(backup: B? = nil, buttonStyle: B.Type = B.self) -> some View {
        #if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26, macOS 26, macCatalyst 26, tvOS 26, watchOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else if let backup {
            self.buttonStyle(backup)
        } else {
            self
        }
        #else
        if let backup {
            self.buttonStyle(backup)
        } else {
            self
        }
        #endif
    }
}
