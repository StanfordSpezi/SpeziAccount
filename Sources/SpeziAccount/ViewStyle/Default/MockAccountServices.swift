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
    typealias ViewStyle = DefaultUserIdPasswordAccountSetupViewStyle

    func login(key: String, password: String) async throws {
        print("login \(key) \(password)")
    }

    func signUp(signUpValues: SignUpValues) async throws {
        print("signup \(signUpValues)")
    }

    func resetPassword(key: String) async throws {
        print("resetPassword \(key)")
    }

    // TODO this has to be a computed property!
    var viewStyle: DefaultUserIdPasswordAccountSetupViewStyle<Self> {
        DefaultUserIdPasswordAccountSetupViewStyle(using: self)
    }

    func logout() async throws {
        print("logout")
    }
}
