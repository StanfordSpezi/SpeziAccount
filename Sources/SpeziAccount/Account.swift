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
    /// The ``Account/signedIn`` property determines if the the current Account context is signed in or not yet signed in.
    /// It can be easily based around as a binding.
    ///
    /// - Note: If the property is set to true, it is guaranteed that ``user`` is present. However, it is recommended
    ///     to gracefully unwrap the optional if access to the account info is required.
    @Published public var signedIn = false
    @Published public private(set) var user: AccountInformation? // TODO must only be accessible/modifieable through an AccountService!
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
    nonisolated init(account: AccountInformation, active accountService: any AccountService) {
        self.accountServices = [accountService]
        self._user = Published(wrappedValue: account)
        self._activeAccountService = Published(wrappedValue: accountService)

        accountService.inject(account: self)
    }

    // TODO rename!
    public func supplyUserInfo<Service: AccountService>(_ user: AccountInformation, by accountService: Service) {
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
