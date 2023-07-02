//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct RandomAccountService: AccountService {
    var viewStyle: DefaultAccountSetupViewStyle<Self> {
        DefaultAccountSetupViewStyle(using: self)
    }

    func logout() async throws {}
}

// TODO rename to Mock... (PR desc: Current impl provided as is, and are more like Mock implementations, => replace with protocols and Mock implementations!
struct DefaultUsernamePasswordAccountService: UserIdPasswordAccountService {
    func login(userId: String, password: String) async throws {
        print("login \(userId) \(password)")
        try? await Task.sleep(nanoseconds: 1000_000_000)
    }

    func signUp(signupRequest: SignupRequest) async throws {
        print("signup \(signupRequest)")
        try? await Task.sleep(nanoseconds: 1000_000_000)
    }

    func resetPassword(userId: String) async throws {
        print("resetPassword \(userId)")
        try? await Task.sleep(nanoseconds: 1000_000_000)
    }

    func logout() async throws {
        print("logout")
        try? await Task.sleep(nanoseconds: 1000_000_000)
    }
}
