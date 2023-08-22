//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import SwiftUI

private struct MockButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SignInWithAppleButton { _ in
            // request
        } onCompletion: { _ in
            // result
        }
            .frame(height: 55)
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
    }
}


struct MockSignInWithAppleProvider: IdentityProvider {
    func makeSignInButton() -> some View {
        MockButton()
    }
}
