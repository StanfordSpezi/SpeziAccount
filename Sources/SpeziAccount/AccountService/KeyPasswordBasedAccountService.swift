//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

protocol KeyPasswordBasedAccountService: AccountService, EmbeddableAccountService where ViewStyle: KeyPasswordBasedAccountSetupViewStyle {
    func login(key: String, password: String) async throws

    func signUp(signUpValues: SignUpValues) async throws // TODO refactor SignUpValues property names!

    func resetPassword(key: String) async throws
}
