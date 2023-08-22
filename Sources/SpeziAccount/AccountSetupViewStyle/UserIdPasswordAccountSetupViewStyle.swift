//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A view style defining UI components for an associated ``UserIdPasswordAccountService``.
public protocol UserIdPasswordAccountSetupViewStyle: EmbeddableAccountSetupViewStyle where Service: UserIdPasswordAccountService {
    /// A view that is rendered to signup a new user.
    associatedtype SignupView: View
    /// A view that is rendered to reset the user's password.
    associatedtype PasswordResetView: View

    /// The view that is presented to signup a new user.
    @ViewBuilder
    func makeSignupView() -> SignupView

    /// The view that is presented to reset a user's password.
    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView
}
