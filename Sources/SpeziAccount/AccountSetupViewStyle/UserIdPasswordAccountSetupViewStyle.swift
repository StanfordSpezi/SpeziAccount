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

    @ViewBuilder
    func makeSignupView() -> SignupView

    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView
}

// TODO move to Default folder as extension file
extension UserIdPasswordAccountSetupViewStyle {
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

    public func makeAccountSummary(account: AccountDetails) -> some View {
        DefaultUserIdPasswordAccountSummaryView(account: account)
    }

    public func makeAccountServiceButtonLabel() -> some View {
        Group {
            service.configuration.image
                .font(.title2)
            Text(service.configuration.name)
        }
            .accountServiceButtonBackground()
    }
}
