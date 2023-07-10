//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct DefaultAccountSetupViewStyle<Service: AccountService>: AccountSetupViewStyle {
    public var service: Service

    init(using service: Service) {
        self.service = service
    }

    public func makeAccountServiceButtonLabel() -> some View {
        Group {
            Image(systemName: "ellipsis.rectangle")
                .font(.title2)
            Text("Mock Account Service")
        }
            .accountServiceButtonBackground()
    }

    public func makePrimaryView() -> some View {
        Text("Hello World")
    }

    public func makeAccountSummary(account: AccountDetails) -> some View {
        Text("Account for \(account.userId)")
    }
}
