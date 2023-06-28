//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


public protocol UserIdPasswordAccountSetupViewStyle: EmbeddableAccountSetupViewStyle where Service: UserIdPasswordAccountService {
    associatedtype SignupView: View
    associatedtype PasswordResetView: View
    // TODO provide embedded primary view (simplified?) ! if its the single element
    // TODO provide a button!
    //  -> Primary View (navigate to sing up if it doesn't exists)
    //  -> Signup View
    //  -> Password Reset view!

    @ViewBuilder
    func makeSignupView() -> SignupView

    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView
}

// TODO move to Default folder as extension file
extension UserIdPasswordAccountSetupViewStyle {
    func makePrimaryView() -> some View {
        DefaultUserIdPasswordPrimaryView(using: service) // TODO pass all the other things!
    }

    func makeEmbeddedAccountView() -> some View {
        DefaultUserIdPasswordEmbeddedView(using: service) // TODO pass all the other things!
    }

    func makeSignupView() -> some View {
        DefaultUserIdPasswordSignUpView(using: service, signUpOptions: .default) // TODO pass all the other things!
    }

    func makePasswordResetView() -> some View {
        DefaultUserIdPasswordResetView(using: service, onSuccess: {
            DefaultSuccessfulPasswordResetView()
        })
    }

    func makeAccountServiceButtonLabel() -> some View {
        // TODO how to generate a sensible default!
        Text("Default button!")
            .accountServiceButtonBackground()
    }

    func makeAccountSummary() -> some View {
        // TODO default implementation!
        Text("Placeholder account summary!")
    }
}
