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

    public nonisolated var viewStyle: some AccountSetupViewStyle {
        MockSimpleAccountSetupViewStyle(using: self)
    }

    public func logout() async throws {
        print("Logout")
    }
}
