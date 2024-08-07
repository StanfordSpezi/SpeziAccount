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
/// You can access the current user account state using the `Account` `Module`.
/// It provides information if the user is currently ``Account/signedIn`` and allows to access the user ``Account/details``.
///
/// - Note: For more information on how to access and use the `Account` object when implementing a custom ``AccountService``
///     refer to the <doc:Creating-your-own-Account-Service> article.
///
/// Below is a short code example demonstrating how to access `Account` from your SwiftUI view hierarchy.
/// ```swift
/// struct MyView: View {
///     @Environment(Account.self)
///     private var account
///
///     var body: some View {
///         // ...
///     }
/// }
/// ```
///
///
/// Accessing the `Account` from within your `Module` is equally simple using the Spezi dependency system.
///
/// ```swift
/// final class MyModule: Module {
///     @Dependency(Account.self)
///     private var account
/// }
/// ```
///
/// - Note: The code example declares a required dependency and would crash if the user doesn't configure `SpeziAccount`.
///     You might want to consider it as an optional dependency to gracefully handle the case where `SpeziAccount` might not be configured.
///
/// ## Topics
///
/// ### Associated User Account
/// Determine account association status and retrieve associated user details.
///
/// - ``signedIn``
/// - ``details``
///
/// ### Managing Account State
/// Manage user account association as an `AccountService`.
///
/// - ``supplyUserDetails(_:)``
/// - ``removeUserDetails()``
@Observable
public final class Account {
    @ObservationIgnored @Application(\.logger)
    var logger // swiftlint:disable:this attributes

    @Dependency @ObservationIgnored private var notifications = AccountNotifications()

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

    /// The user details of the currently associated user account.
    ///
    /// - Note: The ``AccountDetails`` acts as a typed collection and is implemented as a
    /// [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository).
    @MainActor public private(set) var details: AccountDetails?

    @MainActor private weak var _accountService: (any AccountService)?

    /// The account service that was configured.
    @MainActor public var accountService: any AccountService {
        guard let service = _accountService else {
            preconditionFailure("Tried to access account service that was deallocated!")
        }
        return service
    }

    /// The account setup components specified via the ``IdentityProvider`` property wrapper that are shown in the ``AccountSetup`` view.
    let accountSetupComponents: [AnyAccountSetupComponent]
    /// A security related modifier (see ``SecurityRelatedModifier``).
    let securityRelatedModifiers: [AnySecurityModifier]

    /// Initialize a new `Account` object by providing all properties individually.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - supportedConfiguration: The ``AccountValueConfiguration`` to user intends to support.
    ///   - details: A initial ``AccountDetails`` object. The ``signedIn`` is set automatically based on the presence of this argument.
    init(
        service: some AccountService,
        supportedConfiguration: AccountValueConfiguration = .default,
        details: AccountDetails? = nil
    ) {
        self.configuration = supportedConfiguration

        self._signedIn = details != nil
        self._details = details
        self.__accountService = service


        let mirror = Mirror(reflecting: service)
        self.accountSetupComponents = mirror.children.reduce(into: []) { partialResult, property in
            guard let provider = property.value as? AnyIdentityProvider else {
                return
            }

            partialResult.append(provider.component)
        }
        self.securityRelatedModifiers = mirror.children.reduce(into: [], { partialResult, property in
            guard let modifier = property.value as? AnySecurityRelatedModifier else {
                return
            }

            partialResult.append(modifier.securityModifier)
        })
    }

    /// Configures the module.
    public func configure() {
        if configuration.userId == nil {
            logger.warning(
                """
                Your AccountConfiguration doesn't have the \\.userId (aka. UserIdKey) configured. \
                A primary, user-visible identifier is recommended with most SpeziAccount components for \
                an optimal user experience. Ignore this warning if you know what you are doing.
                """
            )
        }
    }

    /// Supply the ``AccountDetails`` of the currently logged in user.
    ///
    /// This method is called by the ``AccountService`` every time the state of the user account changes.
    /// Either if the went from no logged in user to having a logged in user, or if the details of the user account changed.
    ///
    /// - Note: Please set the ``AccountDetails/isNewUser`` or ``AccountDetails/isAnonymous`` properties to communicate the type of account details
    ///     supplied to `Account`.
    ///
    /// - Parameter details: The ``AccountDetails`` of the currently logged in user account.
    @MainActor
    public func supplyUserDetails(_ details: AccountDetails) {
        precondition(
            details.contains(AccountKeys.accountId),
            """
            The provided `AccountDetails` do not have the \\.accountId (aka. AccountIdKey) set. \
            A primary, unique and stable user identifier is expected with most SpeziAccount components and \
            will result in those components breaking.
            """
        )

        guard let accountService = _accountService else {
            assertionFailure("The account service was deallocated.")
            return
        }

        var details = details
        details.accountServiceConfiguration = accountService.configuration
        details.password = nil // ensure password never leaks

        let previousDetails = self.details

        self.details = details

        if !signedIn {
            signedIn = true
        }

        Task { @MainActor [notifications, previousDetails, details] in
            do {
                if let previousDetails {
                    try await notifications.reportEvent(.detailsChanged(previousDetails, details))
                } else {
                    try await notifications.reportEvent(.associatedAccount(details))
                }
            } catch {
                logger.error("Account Association event failed unexpectedly: \(error)")
            }
        }
    }

    /// Removes the currently logged in user.
    ///
    /// This method is called by the currently active ``AccountService`` to remove the ``AccountDetails`` of the currently
    /// signed in user and notify others that the user logged out (or the account was removed).
    @MainActor
    public func removeUserDetails() {
        if let details {
            Task { @MainActor [notifications, details] in
                do {
                    try await notifications.reportEvent(.disassociatingAccount(details))
                } catch {
                    logger.error("Account Disassociation event failed unexpectedly: \(error)")
                }
            }
        }


        if signedIn {
            signedIn = false
        }
        details = nil
    }
}


extension Account: @unchecked Sendable {} // unchecked because of the property wrapper storage


extension Account: Module, EnvironmentAccessible {}
