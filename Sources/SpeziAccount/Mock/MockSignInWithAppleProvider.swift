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


struct MockSignInWithAppleProviderStyle: IdentityProviderViewStyle {
    private(set) var service: MockSignInWithAppleProvider

    func makeSignInButton() -> some View {
        MockButton()
    }
}


actor MockSignInWithAppleProvider: IdentityProvider {
    let configuration = AccountServiceConfiguration(name: "Mock SignIn with Apple", supportedKeys: .arbitrary)

    nonisolated var viewStyle: MockSignInWithAppleProviderStyle {
        MockSignInWithAppleProviderStyle(service: self)
    }


    init() {}


    func signUp(signupDetails: SignupDetails) async throws {
        print("Signup: \(signupDetails)")
    }

    func logout() async throws {
        print("Logout")
    }

    func delete() async throws {
        print("Remove")
    }

    func updateAccountDetails(_ modifications: AccountModifications) async throws {
        print("Modifications: \(modifications)")
    }
}
