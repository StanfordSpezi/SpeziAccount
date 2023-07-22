//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension UserIdPasswordAccountSetupViewStyle {
    public func makePrimaryView() -> some View {
        UserIdPasswordPrimaryView(using: service)
    }

    public func makeEmbeddedAccountView() -> some View {
        UserIdPasswordEmbeddedView(using: service)
    }

    public func makeSignupView() -> some View {
        SignupForm(using: service)
    }

    public func makePasswordResetView() -> some View {
        UserIdPasswordResetView(using: service) {
            SuccessfulPasswordResetView()
        }
    }

    public func makeAccountSummary(account: AccountDetails) -> some View {
        UserIdPasswordAccountSummaryView(account: account)
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