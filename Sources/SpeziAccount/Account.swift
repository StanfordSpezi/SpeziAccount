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
@MainActor
public final class Account: Sendable {
    private let logger: Logger

    /// The `signedIn` property determines if the the current Account context is signed in or not yet signed in.
    ///
    /// You might use the projected value `$signedIn` to get access to the corresponding publisher.
    ///
    /// - Important: If the property is set to `true`, it is guaranteed that ``details`` is present.
    ///     This has the following implications. When `signedIn` is `false`, there might still be a `details` instance present.
    ///     Similarly, when `details` is set to `nil, `signedIn` is guaranteed to be `false`. Otherwise,
    ///     if `details` is set to some value, the `signedIn` property might still be set to `false`.
    public private(set) var signedIn: Bool

    /// Provides access to associated data of the currently associated user account.
    ///
    /// The ``AccountDetails`` acts as a typed collection and is implemented as a
    /// [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository).
    ///
    /// - Note: The associated ``AccountService`` that is responsible for managing the associated user can be retrieved
    ///     using the ``AccountDetails/accountService`` property.
    public private(set) var details: AccountDetails?

    /// The user-defined configuration of account values that all user accounts need to support.
    public let configuration: AccountValueConfiguration

    ///  An account provides a collection of ``AccountService``s that are used to populate login, sign up, or reset password screens.
    ///
    /// - Note: This array also contains ``IdentityProvider``s that need to be treated differently due to differing
    ///     ``AccountSetupViewStyle`` implementations (see ``IdentityProviderViewStyle``).
    public let registeredAccountServices: [any AccountService]

    /// Initialize a new `Account` object by providing all properties individually.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - supportedConfiguration: The ``AccountValueConfiguration`` to user intends to support.
    ///   - details: A initial ``AccountDetails`` object. The ``signedIn`` is set automatically based on the presence of this argument.
    nonisolated init(
        services: [any AccountService],
        supportedConfiguration: AccountValueConfiguration = .default,
        details: AccountDetails? = nil
    ) {
        self.logger = LoggerKey.defaultValue

        // we have to initialize the macro generated properties directly to stay non-isolated.
        self._signedIn = details != nil
        self._details = details

        self.configuration = supportedConfiguration
        self.registeredAccountServices = services

        if supportedConfiguration[UserIdKey.self] == nil {
            logger.warning(
                """
                Your AccountConfiguration doesn't have the \\.userId (aka. UserIdKey) configured. \
                A primary, user-visible identifier is recommended with most SpeziAccount components for \
                an optimal user experience. Ignore this warning if you know what you are doing.
                """
            )
        }

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
    public nonisolated convenience init(
        services: [any AccountService],
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(services: services, supportedConfiguration: configuration)
    }

    /// Initializes a new `Account` object without a logged in user for usage within a `PreviewProvider`.
    ///
    /// To use this within your `PreviewProvider` just supply it to a `environmentObject(_:)` modified in your view hierarchy.
    /// - Parameters:
    ///   - services: A collection of ``AccountService`` that are used to handle account-related functionality.
    ///   - configuration: The ``AccountValueConfiguration`` to user intends to support.
    public nonisolated convenience init(
        _ services: any AccountService...,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(services: services, supportedConfiguration: configuration)
    }

    /// Initializes a new `Account` object with a logged in user for usage within a `PreviewProvider`.
    ///
    /// To use this within your `PreviewProvider` just supply it to a `environmentObject(_:)` modified in your view hierarchy.
    /// - Parameters:
    ///   - builder: A  ``AccountValuesBuilder`` for ``AccountDetails`` with all account details for the logged in user.
    ///   - accountService: The ``AccountService`` that is managing the provided ``AccountDetails``.
    ///   - configuration: The ``AccountValueConfiguration`` to user intends to support.
    public nonisolated convenience init<Service: AccountService>(
        building builder: AccountDetails.Builder,
        active accountService: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(services: [accountService], supportedConfiguration: configuration, details: builder.build(owner: accountService))
    }


    nonisolated func injectWeakAccount(into value: Any) {
        let mirror = Mirror(reflecting: value)

        for (_, value) in mirror.children {
            if let weakReference = value as? _WeakInjectable<Account> { // see AccountService.AccountReference
                weakReference.inject(self)
            } else if let accountService = value as? any AccountService {
                // allow for nested injection like in the case of `StandardBackedAccountService`
                injectWeakAccount(into: accountService)
            }
        }
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
    public func supplyUserDetails(_ details: AccountDetails, isNewUser: Bool = false) async throws {
        precondition(
            details.contains(AccountIdKey.self),
            """
            The provided `AccountDetails` do not have the \\.accountId (aka. AccountIdKey) set. \
            A primary, unique and stable user identifier is expected with most SpeziAccount components and \
            will result in those components breaking.
            """
        )

        var details = details

        if isNewUser { // mark the account details to be from a new user
            details.patchIsNewUser(true)
        }


        // Account details will always get built by the respective Account Service. Therefore, we need to patch it
        // if they are wrapped into a StandardBacked one such that the `AccountDetails` carry the correct reference.
        for service in registeredAccountServices {
            if let standardBacked = service as? any _StandardBacked,
               standardBacked.isBacking(service: details.accountService) {
                details.patchAccountService(service)
                break
            }
        }

        if let existingDetails = self.details,
           existingDetails.accountService.id != details.accountService.id {
            logger.warning("The AccountService \(details.accountService.description) is overwriting `AccountDetails` from \(existingDetails.accountService.description)!")
        }

        // Check if the account service is wrapped with a storage standard. If that's the case, contact them about the signup!
        if let standardBacked = details.accountService as? any _StandardBacked,
           let storageStandard = standardBacked.standard as? any AccountStorageConstraint {
            let recordId = AdditionalRecordId(serviceId: standardBacked.backedId, accountId: details.accountId)

            try await standardBacked.preUserDetailsSupply(recordId: recordId)

            let unsupportedKeys = details.accountService.configuration
                .unsupportedAccountKeys(basedOn: configuration)
                .map { $0.key }

            let partialDetails = try await storageStandard.load(recordId, unsupportedKeys)

            self.details = details.merge(with: partialDetails, allowOverwrite: false)
        } else {
            self.details = details
        }

        if !signedIn {
            signedIn = true
        }
    }

    /// Removes the currently logged in user.
    ///
    /// This method is called by the currently active ``AccountService`` to remove the ``AccountDetails`` of the currently
    /// signed in user and notify others that the user logged out (or the account was removed).
    public func removeUserDetails() async {
        if let details,
           let standardBacked = details.accountService as? any _StandardBacked,
           let storageStandard = standardBacked.standard as? any AccountStorageConstraint {
            let recordId = AdditionalRecordId(serviceId: standardBacked.backedId, accountId: details.accountId)

            await storageStandard.clear(recordId)
        }

        if signedIn {
            signedIn = false
        }
        details = nil
    }
}
