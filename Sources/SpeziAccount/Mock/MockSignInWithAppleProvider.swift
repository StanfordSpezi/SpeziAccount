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


/// Mock ``IdentityProviderViewStyle`` view style for the ``MockSignInWithAppleProvider``.
public struct MockSignInWithAppleProviderStyle: IdentityProviderViewStyle {
    public func makeSignInButton(_ provider: any IdentityProvider) -> some View {
        MockButton()
    }
}


/// A mock implementation of a ``IdentityProvider`` that can be used in your SwiftUI Previews.
///
/// ## Topics
/// ### Mock View Style
/// - ``MockSignInWithAppleProviderStyle``
public actor MockSignInWithAppleProvider: IdentityProvider {
    public let configuration = AccountServiceConfiguration(name: "Mock SignIn with Apple", supportedKeys: .arbitrary)

    public let viewStyle = MockSignInWithAppleProviderStyle()


    public init() {}


    public func signUp(signupDetails: SignupDetails) async throws {
        print("Signup: \(signupDetails)")
    }

    public func logout() async throws {
        print("Logout")
    }

    public func delete() async throws {
        print("Remove")
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        print("Modifications: \(modifications)")
    }
}
