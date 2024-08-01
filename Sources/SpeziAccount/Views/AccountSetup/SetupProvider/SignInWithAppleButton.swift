//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import Foundation
import Spezi
import SwiftUI


/// Create a Sign in with Apple button with Spezi Account support.
///
/// This view augments the [`SignInWithAppleButton`](https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton)
/// with additional support for `SpeziAccount`-related functionality. For example, it automatically controls the
/// [`Label`](https://developer.apple.com/documentation/authenticationservices/signinwithapplebutton/label)
/// based on the ``PreferredSetupStyle``.
public struct SignInWithAppleButton: View {
    private let overrideLabel: AuthenticationServices.SignInWithAppleButton.Label?
    private let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    private let onCompletion: (Result<ASAuthorization, any Error>) -> Void

    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.preferredSetupStyle)
    private var preferredSetupStyle

    private var label: AuthenticationServices.SignInWithAppleButton.Label {
        if let overrideLabel {
            return overrideLabel
        }

        switch preferredSetupStyle {
        case .automatic, .login:
            return .signIn
        case .signup:
            return .signUp
        }
    }

    public var body: some View {
        AuthenticationServices.SignInWithAppleButton(label, onRequest: onRequest, onCompletion: onCompletion)
            .frame(height: 55)
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
    }

    /// Create a new Sign in with Apple button.
    /// - Parameters:
    ///   - label: Optionally override the label that is used for the button. Otherwise, it will be derived from the ``PreferredSetupStyle``.
    ///   - onRequest: The authorization request for an Apple ID.
    ///   - onCompletion: The completion handler that the system calls when the sign-in completes.
    public init(
        _ label: AuthenticationServices.SignInWithAppleButton.Label? = nil,
        onRequest: @escaping (ASAuthorizationAppleIDRequest) -> Void,
        onCompletion: @escaping ((Result<ASAuthorization, any Error>) -> Void)
    ) {
        self.overrideLabel = label
        self.onRequest = onRequest
        self.onCompletion = onCompletion
    }
}


#if DEBUG
#Preview {
    SignInWithAppleButton { request in
        request.requestedScopes = [.email, .fullName]
        request.nonce = "ASDF"
    } onCompletion: { result in
        print("Result \(result)")
    }
}
#endif
