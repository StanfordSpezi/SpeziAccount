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
