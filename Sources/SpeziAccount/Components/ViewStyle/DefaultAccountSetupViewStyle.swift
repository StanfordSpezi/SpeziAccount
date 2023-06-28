//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct DefaultAccountSetupViewStyle<Service: AccountService>: AccountSetupViewStyle {
    var service: Service

    init(using service: Service) {
        self.service = service
    }

    func makeAccountServiceButtonLabel() -> some View {
        // TODO this method is currently called label, but the AccountServiceButton is called button => confusing!
        //  => make it a modifier!
        Group {
            Image(systemName: "ellipsis.rectangle")
                .font(.title2)
            Text("Mock Account Service")
        }
            .accountServiceButtonBackground()
    }

    func makePrimaryView() -> some View {
        Text("Hello World")
    }

    func makeAccountSummary() -> some View {
        Text("Conditionally show Account summary, or login stuff!")
    }
}
