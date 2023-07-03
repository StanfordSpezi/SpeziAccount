//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// Account-related Spezi module managing a collection of ``AccountService``s.
/// TODO update docs!
/// 
/// The ``Account/Account`` type also enables interaction with the ``AccountService``s from anywhere in the view hierarchy.
@MainActor
public class Account: ObservableObject {
    /// The ``Account/Account/signedIn`` determines if the the current Account context is signed in or not yet signed in.
    @Published public var signedIn = false
    @Published public private(set) var user: UserInfo? // TODO must only be accessible/modifieable through an AccountService!
    @Published public private(set) var activeAccountService: (any AccountService)?

    // TODO how to get to the account service that holds the active account?

    // TODO make a configuration objet, where all other account services may enter themselves!

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    nonisolated let accountServices: [any AccountService]

    
    /// - Parameter services: An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    public nonisolated init(services: [any AccountService] = []) {
        self.accountServices = services
        for service in services {
            service.inject(account: self)
        }
    }

    /// Initializer useful for testing and previewing purposes.
    nonisolated init(account: UserInfo, active accountService: any AccountService) {
        self.accountServices = [accountService]
        self._user = Published(wrappedValue: account)
        self._activeAccountService = Published(wrappedValue: accountService)

        accountService.inject(account: self)
    }

    public func supplyUserInfo<Service: AccountService>(_ user: UserInfo, by accountService: Service) {
        if let activeAccountService {
            precondition(ObjectIdentifier(accountService) == ObjectIdentifier(activeAccountService)) // TODO message
        }

        self.activeAccountService = accountService
        self.user = user
        if !signedIn {
            signedIn = true
        }
    }

    public func removeUserInfo<Service: AccountService>(by accountService: Service) {
        if let activeAccountService {
            precondition(ObjectIdentifier(accountService) == ObjectIdentifier(activeAccountService)) // TODO message
        }
        if signedIn {
            signedIn = false
        }
        user = nil
        activeAccountService = nil
    }
}
