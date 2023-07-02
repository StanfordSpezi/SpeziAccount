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
public actor Account: ObservableObject {
    /// The ``Account/Account/signedIn`` determines if the the current Account context is signed in or not yet signed in.
    @MainActor
    public var signedIn: Bool {
        account != nil
    }

    @MainActor
    @Published
    public private(set) var account: AccountValuesWhat? // TODO UserAccount/User! TODO must only be accessible/modifieable through an AccountService!

    // TODO how to get to the account service that holds the active account?

    // TODO make a configuration objet, where all other account services may enter themselves!
    
    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    nonisolated let accountServices: [any AccountService]
    
    
    /// - Parameter accountServices: An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    public init(accountServices: [any AccountService]) {
        self.accountServices = accountServices
        // TODO for accountService in accountServices {
        //    accountService.inject(account: self)
        // }
    }

    init(accountServices: [any AccountService] = [], account: AccountValuesWhat) {
        self.accountServices = accountServices
        self._account = Published(wrappedValue: account)
    }
}

public struct AccountValuesWhat: Sendable, ModifiableAccountValueStorageContainer { // TODO naming is off!
    public var storage: AccountValueStorage

    public init(storage: AccountValueStorage) {
        self.storage = storage
    }
}
