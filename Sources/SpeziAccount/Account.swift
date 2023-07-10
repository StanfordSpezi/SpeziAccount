//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

// TODO naming?
typealias AccountReference = WeakInjectable<Account>

@propertyWrapper
public final class WeakInjectable<Type: AnyObject> { // TODO where to move?
    private weak var weakReference: Type?

    public var wrappedValue: Type {
        guard let weakReference else {
            fatalError("Failed to retrieve `\(Type.self)` object from weak reference is not yet present or not present anymore.")
        }

        return weakReference
    }

    public init() {}

    func inject(_ type: Type) {
        self.weakReference = type
    }
}

extension WeakInjectable: Sendable where Type: Sendable {}

/// Account-related Spezi module managing a collection of ``AccountService``s.
/// TODO update docs!
/// 
/// The ``Account/Account`` type also enables interaction with the ``AccountService``s from anywhere in the view hierarchy.
@MainActor
public class Account: ObservableObject, Sendable {
    /// The ``Account/signedIn`` property determines if the the current Account context is signed in or not yet signed in.
    /// It can be easily based around as a binding. TODO not true?
    ///
    /// - Note: If the property is set to true, it is guaranteed that ``details`` is present. However, it is recommended
    ///     to gracefully unwrap the optional if access to the account info is required.
    @Published public private(set) var signedIn = false
    @Published public private(set) var details: AccountDetails?

    // TODO make a configuration objet, where all other account services may enter themselves!

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    let mappedAccountServices: [AccountService.ID: any AccountService]
    var accountServices: [any AccountService] { // TODO list needs an array?
        Array(mappedAccountServices.values)
    }

    
    /// - Parameter services: An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    public nonisolated init(services: [any AccountService] = []) {
        self.mappedAccountServices = services.reduce(into: [:]) { partialResult, service in
            partialResult[service.id] = service
        }

        for service in mappedAccountServices.values {
            injectWeakAccount(into: service)
        }
    }

    /// Initializer useful for testing and previewing purposes.
    convenience init<Service: AccountService>(building builder: AccountDetails.Builder, active accountService: Service) {
        self.init(services: [accountService])

        self.supplyUserInfo(builder.build(owner: accountService))
    }

    private nonisolated func injectWeakAccount(into value: Any) {
        let mirror = Mirror(reflecting: value)

        for (_, value) in mirror.children {
            if let weakReference = value as? AccountReference {
                weakReference.inject(self)
            }
        }
    }

    // TODO rename!
    public func supplyUserInfo(_ details: AccountDetails) {
        if let existingDetails = self.details {
            precondition(
                existingDetails.accountServiceId == details.accountServiceId,
                "The AccountService \(details.accountService) tried to overwrite `AccountDetails` from \(existingDetails.accountService)!"
            )
        }

        injectWeakAccount(into: details)

        // TODO document order!
        self.details = details
        if !signedIn {
            signedIn = true
        }
    }

    public func removeUserInfo() { // TODO rename
        /*
         TODO how to check if the right account service removes the user info?
        if let activeAccountService {
            precondition(ObjectIdentifier(accountService) == ObjectIdentifier(activeAccountService)) // TODO message
        }
        */
         // TODO document order!
        if signedIn {
            signedIn = false
        }
        details = nil
    }
}
