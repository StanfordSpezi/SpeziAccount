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
    // TODO review if we missed to pass any options to the default constructors
    public func makePrimaryView() -> some View {
        DefaultUserIdPasswordPrimaryView(using: service)
    }

    public func makeEmbeddedAccountView() -> some View {
        DefaultUserIdPasswordEmbeddedView(using: service)
    }

    public func makeSignupView() -> some View {
        DefaultUserIdPasswordSignUpView(using: service)
    }

    public func makePasswordResetView() -> some View {
        DefaultUserIdPasswordResetView(using: service) {
            DefaultSuccessfulPasswordResetView()
        }
    }

    public func makeAccountSummary() -> some View {
        DefaultUserIdPasswordAccountSummaryView(using: service)
    }

    public func makeAccountServiceButtonLabel() -> some View {
        // TODO how to generate a sensible default!
        Group {
            service.configuration.image
                .font(.title2)
            Text(service.configuration.name)
        }
        .accountServiceButtonBackground()
    }
}
