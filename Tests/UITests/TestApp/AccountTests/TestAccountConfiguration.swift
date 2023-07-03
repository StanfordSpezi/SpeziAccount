//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import Spezi
import SpeziAccount


final class TestAccountConfiguration<ComponentStandard: Standard>: AccountServiceProvider {
    var accountService: TestUsernamePasswordAccountService

    init() {
        self.accountService = TestUsernamePasswordAccountService()
        // TODO how to supply the email account service!
    }
}
