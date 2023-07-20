//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// Account-related Spezi module managing a collection of ``AccountService``s and provide access to ``AccountDetails``
/// of the currently associated user account.
/// TODO update docs!
/// 
/// The ``Account/Account`` type also enables interaction with the ``AccountService``s from anywhere in the view hierarchy.
@MainActor
public class Account: ObservableObject, Sendable {
    /// The `signedIn` property determines if the the current Account context is signed in or not yet signed in.
    ///
    /// You might use the projected value `$signedIn` to get access to the corresponding publisher.
    ///
    /// - Important: If the property is set to `true`, it is guaranteed that ``details`` is present.
    ///     This has the following implications. When `signedIn` is `false`, there might still be a `details` instance present.
    ///     Similarly, when `details` is set to `nil, `signedIn` is guaranteed to be `false`. Otherwise,
    ///     if `details` is set to some value, the `signedIn` property might still be set to `false`.
    @Published public private(set) var signedIn = false

    /// Provides access to associated data of the currently associated user account.
    ///
    /// The ``AccountDetails`` acts as a typed collection and is implemented as a
    /// [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository).
    ///
    /// - Note: The associated ``AccountService`` that is responsible for managing the associated user can be retrieved
    ///     using the ``AccountDetails/accountService`` property.
    @Published public private(set) var details: AccountDetails?

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    let registeredAccountServices: [any AccountService]

    
    /// - Parameter services: An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    public nonisolated init(services: [any AccountService] = []) {
        registeredAccountServices = services

        for service in registeredAccountServices {
            injectWeakAccount(into: service)
        }
    }

    /// Initializer useful for testing and previewing purposes.
    convenience init<Service: AccountService>(building builder: AccountDetails.Builder, active accountService: Service) {
        self.init(services: [accountService])

        self.supplyUserDetails(builder.build(owner: accountService))
    }

    /// Initializer useful for testing and previewing purposes.
    convenience init(_ services: any AccountService...) {
        self.init(services: services)
    }

    nonisolated func injectWeakAccount<V: AccountService>(into value: V) {
        let mirror = Mirror(reflecting: value)

        for (_, value) in mirror.children {
            if let weakReference = value as? V.AccountReference {
                weakReference.inject(self)
            }
        }
    }

    public func supplyUserDetails(_ details: AccountDetails) {
        if let existingDetails = self.details {
            precondition(
                existingDetails.accountService.id == details.accountService.id,
                "The AccountService \(details.accountService) tried to overwrite `AccountDetails` from \(existingDetails.accountService)!"
            )
        }

        self.details = details
        if !signedIn {
            signedIn = true
        }
    }

    public func removeUserDetails() {
        if signedIn {
            signedIn = false
        }
        details = nil
    }
}
