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


final class TestAccountConfiguration: Component {
    @Provide var usernameAccountService: any AccountService
    @Provide var emailAccountService: any AccountService

    init() {
        // TODO we need to somehow tests the different views right?
        self.usernameAccountService = TestUsernamePasswordAccountService()
        self.emailAccountService = TestEmailPasswordAccountService()
    }
}
