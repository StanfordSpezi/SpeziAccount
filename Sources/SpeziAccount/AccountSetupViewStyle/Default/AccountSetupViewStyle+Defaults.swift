//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension AccountSetupViewStyle {
    public func makeServiceButtonLabel() -> some View {
        Group {
            service.configuration.image
                .font(.title2)
            Text(service.configuration.name)
        }
            .accountServiceButtonBackground()
    }

    public func makeAccountSummary(details: AccountDetails) -> some View {
        AccountSummary(account: details)
    }
}
