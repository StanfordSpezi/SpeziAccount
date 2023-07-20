//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// TODO docs!
public struct MockSimpleAccountSetupViewStyle: AccountSetupViewStyle {
    public var service: MockSimpleAccountService

    init(using service: MockSimpleAccountService) {
        self.service = service
    }

    public func makeAccountServiceButtonLabel() -> some View {
        Group {
            Image(systemName: "ellipsis.rectangle")
                .font(.title2)
            Text("Mock Account Service") // TODO configurable?
        }
            .accountServiceButtonBackground()
    }

    public func makePrimaryView() -> some View {
        Text("Hello World") // TODO something at least?
    }

    public func makeAccountSummary(account: AccountDetails) -> some View {
        DefaultUserIdPasswordAccountSummaryView(account: account)
    }
}
