//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct DefaultUserIdPasswordAccountSetupViewStyle<Service: UserIdPasswordAccountService>: UserIdPasswordAccountSetupViewStyle {
    // swiftlint:disable:previous type_name
    public let service: Service

    public init(using service: Service) {
        self.service = service
    }
}
