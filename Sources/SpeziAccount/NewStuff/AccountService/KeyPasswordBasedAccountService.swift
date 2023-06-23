//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

protocol KeyPasswordBasedAccountService: AccountServiceNew, EmbeddableAccountService where ViewStyle: KeyPasswordBasedAccountServiceViewStyle {
    func login(key: String, password: String) async throws

    func signUp(signUpValues: SignUpValues) async throws // TODO refactor SignUpValues property names!

    func resetPassword(key: String) async throws
}

protocol KeyPasswordBasedAccountServiceViewStyle: EmbeddableAccountServiceViewStyle where Service: KeyPasswordBasedAccountService {
    associatedtype SignupView: View
    associatedtype PasswordResetView: View
    associatedtype PasswordForgotView: View
    // TODO provide embedded primary view (simplified?) ! if its the single element
    // TODO provide a button!
    //  -> Primary View (navigate to sing up if it doesn't exists)
    //  -> Signup View
    //  -> Password Reset view!

    @ViewBuilder
    func makeSignupView() -> SignupView

    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView

    @ViewBuilder
    func makePasswordForgotView() -> PasswordForgotView
}

extension KeyPasswordBasedAccountServiceViewStyle {
    func makePrimaryView() -> some View {
        EmptyView() // TODO implement
    }

    func makeEmbeddedAccountView() -> some View {
        DefaultKeyPasswordBasedEmbeddedView(using: accountService)
    }

    func makeSignupView() -> some View {
        EmptyView() // TODO implement
    }

    func makePasswordResetView() -> some View {
        EmptyView() // TODO implement
    }

    func makePasswordForgotView() -> some View {
        EmptyView() // TODO implement
    }
}
