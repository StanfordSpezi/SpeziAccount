//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct DefaultUserIdPasswordAccountSetupViewStyle<Service: UserIdPasswordAccountService>: UserIdPasswordAccountSetupViewStyle {
    // swiftlint:disable:previous type_name

    var service: Service

    init(using service: Service) {
        self.service = service
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
