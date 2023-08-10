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
/// The ``Account`` type also enables interaction with the ``AccountService``s from anywhere in the view hierarchy.
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

    public let signupRequirements: AccountValueRequirements

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    let registeredAccountServices: [any AccountService]

    /// TODO docs
    /// - Parameters:
    ///   - services: An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    ///   - signupRequirements: TODO docs
    public nonisolated init(
        services: [any AccountService] = [],
        requirements signupRequirements: AccountValueRequirements = .default // TODO make something minimal (for Firebase)
    ) {
        self.registeredAccountServices = services
        self.signupRequirements = signupRequirements

        for service in registeredAccountServices {
            injectWeakAccount(into: service)
        }
    }

    /// Initializer useful for testing and previewing purposes.
    /// - Parameters:
    ///   - builder: // TODO docs!
    ///   - accountService:
    ///   - signupRequirements:
    convenience init<Service: AccountService>(
        building builder: AccountDetails.Builder,
        active accountService: Service,
        requirements signupRequirements: AccountValueRequirements = .default
    ) {
        self.init(services: [accountService], requirements: signupRequirements)

        self.supplyUserDetails(builder.build(owner: accountService))
    }

    /// Initializer useful for testing and previewing purposes.
    convenience nonisolated init(_ services: any AccountService...) {
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
