//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


protocol KeyPasswordBasedAccountSetupViewStyle: EmbeddableAccountSetupViewStyle where Service: KeyPasswordBasedAccountService {
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

// TODO move to Default folder as extension file
extension KeyPasswordBasedAccountSetupViewStyle {
    func makePrimaryView() -> some View {
        EmptyView() // TODO implement
    }

    func makeEmbeddedAccountView() -> some View {
        DefaultKeyPasswordBasedEmbeddedView(using: service)
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
