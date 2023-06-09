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


final class TestAccountConfiguration<ComponentStandard: Standard>: Component, ObservableObjectProvider {
    private let account: Account
    private let user: User
    
    
    var observableObjects: [any ObservableObject] {
        [
            account,
            user
        ]
    }
    
    
    init(emptyAccountServices: Bool = false) {
        self.user = User()
        let accountServices: [any AccountService] = emptyAccountServices
            ? []
            : [
                MockUsernamePasswordAccountService(user: user),
                MockEmailPasswordAccountService(user: user)
            ]
        self.account = Account(accountServices: accountServices)
    }
}
