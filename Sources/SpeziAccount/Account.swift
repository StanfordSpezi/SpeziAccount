//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

// TODO some generic todos:
//  - iterable account details!
//  - allow account services to specify their supported account values (arbitrary, exactly(_:)) and use Standard constraint for storage of additional
//  - also allow account services to specify which account values are required (e.g. userId and password (or a which level?)!); minimal set; extension set!


/// The primary entry point for UI components and ``AccountService``s to interact with ``SpeziAccount`` interfaces.
///
/// The `Account` object is responsible to manage the state of the currently logged in user.
/// You can simply access the currently ``signedIn`` state of the user (or via the `$signedIn` publisher) or
/// access the account information from the ``details`` property (or via the `$details` publisher).
///
/// - Note: For more information on how to access and use the `Account` object when implementing a custom ``AccountService``
///     refer to the <doc:Creating-your-own-Account-Service> article.
///
/// ### Accessing `Account` in your view
///
/// To access the `Account` object from anywhere in your view hierarchy (assuming you have ``AccountConfiguration`` configured),
/// you may just declare the respective `EnvironmentObject` property wrapper as in the code sample below.
///
/// ```swift
/// struct MyView: View {
///     @EnvironmentObject var account: Account
///
///     var body: some View {
///         if let details = account.details {
///             Text("Hello \(details.name.formatted(.name(style: .medium)))")
///         } else {
///             Text("Hello World")
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Retrieving Account state
/// This section provides an overview on how to retrieve the currently logged in user from your views.
///
/// - ``signedIn``
/// - ``details``
///
/// ### Managing Account state
/// This section provides an overview on how to manage and manipulate the current user account as an ``AccountService``.
///
/// - ``supplyUserDetails(_:)``
/// - ``removeUserDetails()``
///
/// ### Initializers for your Preview Provider
///
/// - ``init(services:requirements:)``
/// - ``init(_:requirements:)``
/// - ``init(building:active:requirements:)``
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
    @Published public private(set) var signedIn: Bool

    /// Provides access to associated data of the currently associated user account.
    ///
    /// The ``AccountDetails`` acts as a typed collection and is implemented as a
    /// [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository).
    ///
    /// - Note: The associated ``AccountService`` that is responsible for managing the associated user can be retrieved
    ///     using the ``AccountDetails/accountService`` property.
    @Published public private(set) var details: AccountDetails?

    public let configuration: AccountValueConfiguration // TODO document use, once finalized!

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    let registeredAccountServices: [any AccountService]

    /// Initialize a new `Account` object by providing all properties individually.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - supportedConfiguration: The ``AccountValueConfiguration`` to user intends to support.
    ///   - details: A initial ``AccountDetails`` object. The ``signedIn`` is set automatically based on the presence of this argument.
    private nonisolated init(
        services: [any AccountService],
        supportedConfiguration: AccountValueConfiguration = .default,
        details: AccountDetails? = nil
    ) {
        self._signedIn = Published(wrappedValue: details != nil)
        self._details = Published(wrappedValue: details)
        self.configuration = supportedConfiguration
        self.registeredAccountServices = services

        for service in registeredAccountServices {
            injectWeakAccount(into: service)
        }
    }

    /// Initializes a new `Account` object without a logged in user for usage within a `PreviewProvider`.
    ///
    /// To use this within your `PreviewProvider` just supply it to a `environmentObject(_:)` modified in your view hierarchy.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - configuration: The ``AccountValueConfiguration`` to user intends to support.
    public nonisolated convenience init(services: [any AccountService] = [], configuration: AccountValueConfiguration = .default) {
        self.init(services: services, supportedConfiguration: configuration)
    }

    /// Initializes a new `Account` object without a logged in user for usage within a `PreviewProvider`.
    ///
    /// To use this within your `PreviewProvider` just supply it to a `environmentObject(_:)` modified in your view hierarchy.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - configuration: The ``AccountValueConfiguration`` to user intends to support.
    public nonisolated convenience init(_ services: any AccountService..., configuration: AccountValueConfiguration = .default) {
        self.init(services: services, supportedConfiguration: configuration)
    }

    /// Initializes a new `Account` object with a logged in user for usage within a `PreviewProvider`.
    ///
    /// To use this within your `PreviewProvider` just supply it to a `environmentObject(_:)` modified in your view hierarchy.
    /// - Parameters:
    ///   - builder: A ``AccountDetails/Builder`` with all account details for the logged in user.
    ///   - accountService: The ``AccountService`` that is managing the provided ``AccountDetails``.
    ///   - configuration: The ``AccountValueConfiguration`` to user intends to support. TODO will we check for exposed account value requirements of the account service here in the init?
    public nonisolated convenience init<Service: AccountService>(
        building builder: AccountDetails.Builder,
        active accountService: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(services: [accountService], supportedConfiguration: configuration, details: builder.build(owner: accountService))
    }


    nonisolated func injectWeakAccount<V: AccountService>(into value: V) {
        let mirror = Mirror(reflecting: value)

        for (_, value) in mirror.children {
            if let weakReference = value as? V.AccountReference {
                weakReference.inject(self)
            }
        }
    }

    /// Supply the ``AccountDetails`` of the currently logged in user.
    ///
    /// This method is called by the ``AccountService`` every time the state of the user account changes.
    /// Either if the went from no logged in user to having a logged in user, or if the details of the user account changed.
    ///
    /// - Parameter details: The ``AccountDetails`` of the currently logged in user account.
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

    /// Removes the currently logged in user.
    ///
    /// This method is called by the currently active ``AccountService`` to remove the ``AccountDetails`` of the currently
    /// signed in user and notify others that the user logged out (or the account was removed).
    public func removeUserDetails() {
        if signedIn {
            signedIn = false
        }
        details = nil
    }
}
