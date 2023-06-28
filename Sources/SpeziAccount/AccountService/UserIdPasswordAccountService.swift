//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public protocol UserIdPasswordAccountService: AccountService, EmbeddableAccountService where ViewStyle: UserIdPasswordAccountSetupViewStyle {
    func login(userId: String, password: String) async throws

    // TODO ability to abstract SignUpValues
    func signUp(signUpValues: SignUpValues) async throws // TODO refactor SignUpValues property names!

    func resetPassword(userId: String) async throws
}
