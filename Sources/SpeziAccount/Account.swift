//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import os
import Spezi
import SwiftUI


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
/// you may just declare the respective [@Environment](https://developer.apple.com/documentation/swiftui/environment)
/// property wrapper as in the code sample below.
///
/// ```swift
/// struct MyView: View {
///     @Environment(Account.self) var account
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
/// - ``supplyUserDetails(_:isNewUser:)``
/// - ``removeUserDetails()``
///
/// ### Initializers for your Preview Provider
///
/// - ``init(services:configuration:)``
/// - ``init(_:configuration:)``
/// - ``init(building:active:configuration:)``
@Observable
public final class Account {
    @Application(\.logger) @ObservationIgnored private var logger

    @Dependency @ObservationIgnored private var notifications: AccountNotifications

    /// The user-defined configuration of account values that all user accounts need to support.
    public let configuration: AccountValueConfiguration

    /// The `signedIn` property determines if the the current Account context is signed in or not yet signed in.
    ///
    /// You might use the projected value `$signedIn` to get access to the corresponding publisher.
    ///
    /// - Important: If the property is set to `true`, it is guaranteed that ``details`` is present.
    ///     This has the following implications. When `signedIn` is `false`, there might still be a `details` instance present.
    ///     Similarly, when `details` is set to `nil, `signedIn` is guaranteed to be `false`. Otherwise,
    ///     if `details` is set to some value, the `signedIn` property might still be set to `false`.
    @MainActor public private(set) var signedIn: Bool

    /// Provides access to associated data of the currently associated user account.
    ///
    /// The ``AccountDetails`` acts as a typed collection and is implemented as a
    /// [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository).
    ///
    /// - Note: The associated ``AccountService`` that is responsible for managing the associated user can be retrieved
    ///     using the ``AccountDetails/accountService`` property.
    @MainActor public private(set) var details: AccountDetails?

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    ///
    /// - Note: This array also contains ``IdentityProvider``s that need to be treated differently due to differing
    ///     ``AccountSetupViewStyle`` implementations (see ``IdentityProviderViewStyle``).


    @MainActor public let accountService: (any AccountService) // TODO: this should be weak, (just make it private?)

    let accountSetupComponents: [AnyAccountSetupComponent] // TODO: should that be public?
    let securityRelatedModifiers: [AnySecurityModifier]

    /// Initialize a new `Account` object by providing all properties individually.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - supportedConfiguration: The ``AccountValueConfiguration`` to user intends to support.
    ///   - details: A initial ``AccountDetails`` object. The ``signedIn`` is set automatically based on the presence of this argument.
    init(
        service: some AccountService, // TODO: allow any AccountService?
        supportedConfiguration: AccountValueConfiguration = .default,
        details: AccountDetails? = nil
    ) {
        self.configuration = supportedConfiguration

        self._signedIn = details != nil
        self._details = details
        self.accountService = service


        let mirror = Mirror(reflecting: service)
        self.accountSetupComponents = mirror.children.reduce(into: []) { partialResult, property in
            // TODO: support nesting with ViewProviding!
            guard let provider = property.value as? AnyIdentityProvider else {
                return
            }

            partialResult.append(provider.component)
        } // TODO: sort by placement (only if we disallow to enable that?)
        self.securityRelatedModifiers = mirror.children.reduce(into: [], { partialResult, property in
            guard let modifier = property.value as? AnySecurityRelatedModifier else {
                return
            }

            partialResult.append(modifier.securityModifier)
        })

        if supportedConfiguration[UserIdKey.self] == nil {
            logger.warning(
                """
                Your AccountConfiguration doesn't have the \\.userId (aka. UserIdKey) configured. \
                A primary, user-visible identifier is recommended with most SpeziAccount components for \
                an optimal user experience. Ignore this warning if you know what you are doing.
                """
            )
        }
    }

    public required init() {
        // TODO: account services would need to make them all optional?
        preconditionFailure("Cannot default initialize. This is to workaround an issue with the @Dependency property wrapper in Spezi account!")
    }

    /// Supply the ``AccountDetails`` of the currently logged in user.
    ///
    /// This method is called by the ``AccountService`` every time the state of the user account changes.
    /// Either if the went from no logged in user to having a logged in user, or if the details of the user account changed.
    ///
    /// - Parameters:
    ///   - details: The ``AccountDetails`` of the currently logged in user account.
    ///   - isNewUser: An optional flag that indicates if the provided account details are for a new user registration.
    ///     If this flag is set to `true`, the ``AccountSetup`` view will render a additional information sheet not only for
    ///     ``AccountKeyRequirement/required``, but also for ``AccountKeyRequirement/collected`` account values.
    ///     This is primarily helpful for identity providers. You might not want to set this flag
    ///     if you using the builtin ``SignupForm``!
    @MainActor
    public func supplyUserDetails(_ details: AccountDetails, isNewUser: Bool = false) async throws {
        // TODO: remove Standard interaction, make non-async
        precondition(
            details.contains(AccountIdKey.self),
            """
            The provided `AccountDetails` do not have the \\.accountId (aka. AccountIdKey) set. \
            A primary, unique and stable user identifier is expected with most SpeziAccount components and \
            will result in those components breaking.
            """
        )

        var details = details
        details.patchAccountServiceConfiguration(accountService.configuration)

        if isNewUser { // mark the account details to be from a new user
            details.patchIsNewUser(true)
        }

        let isUpdating = self.details != nil

        self.details = details

        if !signedIn {
            signedIn = true
        }

        if isUpdating {
            try await notifications.reportEvent(.detailsChanged, for: details.accountId)
        } else {
            try await notifications.reportEvent(.associatedAccount, for: details.accountId)
        }
    }

    /// Removes the currently logged in user.
    ///
    /// This method is called by the currently active ``AccountService`` to remove the ``AccountDetails`` of the currently
    /// signed in user and notify others that the user logged out (or the account was removed).
    @MainActor
    public func removeUserDetails() async {
        if let details {
            try? await notifications.reportEvent(.disassociatingAccount, for: details.accountId)
        }


        if signedIn {
            signedIn = false
        }
        details = nil
    }
}


extension Account: @unchecked Sendable {} // unchecked because of the property wrapper storage


extension Account: Module, EnvironmentAccessible, DefaultInitializable {}
