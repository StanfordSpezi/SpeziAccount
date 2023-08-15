//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// TODO docs!
public actor MockSimpleAccountService: AccountService {
    @AccountReference private var account: Account

    public let configuration = AccountServiceConfiguration(name: "Mock Simple AccountService")


    public nonisolated var viewStyle: some AccountSetupViewStyle {
        MockSimpleAccountSetupViewStyle(using: self)
    }


    public init() {}


    public func signUp(signupDetails: SignupDetails) async throws {
        print("Signup: \(signupDetails)")
    }

    public func logout() async throws {
        print("Logout")
    }

    public func delete() async throws {
        print("Remove")
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        print("Modifications: \(modifications)")
    }
}
