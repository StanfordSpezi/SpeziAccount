//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import XCTRuntimeAssertions


/// Configure the `SpeziAccount` framework.
///
/// This Spezi `Module` is used to configure the `SpeziAccount` framework.
/// You provide the ``AccountService`` module that should be used with the framework.
/// The ``Account`` module will be injected as an environment object into the view hierarchy of your app and is accessible
/// using the `@Dependency` property wrapper from other Spezi `Module`s.
///
/// - Note: For more information on how to provide an ``AccountService`` refer to the <doc:Creating-your-own-Account-Service> article.
public final class AccountConfiguration<Service: AccountService> {
    @Application(\.logger)
    private var logger

    @Dependency(Account.self)
    private var account
    @Dependency(ExternalAccountStorage.self)
    private var externalStorage
    @Dependency(Service.self)
    private var accountService

    @Dependency private var storageProvider: [any Module] // we store the storage provider in a type erased way! it is optional to supply!
    @StandardActor private var standard: any Standard


    @Modifier private var verifyRequiredConfiguration = VerifyRequiredAccountDetailsModifier()

    /// Configure the `SpeziAccount` framework.
    ///
    /// Provide an ``AccountService`` implementation that manages all account-related operations.
    ///
    /// - Parameters:
    ///   - service: The `AccountService` to use with the framework.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    public convenience init(
        service: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(accountService: service, configuration: configuration)
    }

    /// Configure the `SpeziAccount` framework with external storage.
    ///
    /// Provide an ``AccountService`` implementation that manages all account-related operations.
    /// Use this to supply an ``AccountStorageProvider`` that manages external storage of account values unsupported by the account service.
    ///
    /// - Parameters:
    ///   - service: The `AccountService` to use with the framework.
    ///   - storageProvider: The storage provider that will be used to store additional account details.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    public convenience init<Storage: AccountStorageProvider>(
        service: Service,
        storageProvider: Storage,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(accountService: service, storageProvider: storageProvider, configuration: configuration)
    }

    /// Configure the `Account` Module for previewing purposes.
    ///
    /// - Parameters:
    ///   - service: The `AccountService` to use with the framework.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    ///   - activeDetails: The  account details you want to simulate.
    @_spi(TestingSupport)
    public convenience init( // swiftlint:disable:this function_default_parameter_at_end
        service: Service,
        configuration: AccountValueConfiguration = .default,
        activeDetails: AccountDetails
    ) {
        self.init(accountService: service, configuration: configuration, defaultActiveDetails: activeDetails)
    }

    /// Configure the `Account` Module for previewing purposes with external storage.
    ///
    /// - Parameters:
    ///   - service: The `AccountService` to use with the framework.
    ///   - storageProvider: The storage provider that will be used to store additional account details.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    ///   - activeDetails: The  account details you want to simulate.
    @_spi(TestingSupport)
    public convenience init<Storage: AccountStorageProvider>( // swiftlint:disable:this function_default_parameter_at_end
        service: Service,
        storageProvider: Storage,
        configuration: AccountValueConfiguration = .default,
        activeDetails: AccountDetails
    ) {
        self.init(accountService: service, storageProvider: storageProvider, configuration: configuration, defaultActiveDetails: activeDetails)
    }

    init( // swiftlint:disable:this function_default_parameter_at_end
        accountService: Service,
        storageProvider: (any AccountStorageProvider)? = nil,
        configuration: AccountValueConfiguration,
        defaultActiveDetails: AccountDetails? = nil
    ) {
        self._accountService = Dependency(load: accountService)
        self._storageProvider = Dependency {
            if let storageProvider {
                storageProvider
            }
        }

        self._account = Dependency(wrappedValue: Account(
            service: accountService,
            supportedConfiguration: configuration,
            details: defaultActiveDetails
        ))
        self._externalStorage = Dependency(wrappedValue: ExternalAccountStorage(storageProvider))
    }

    /// Configure the module.
    @MainActor
    public func configure() {
        // Verify account service can store all configured account keys.
        // If applicable, wraps the service into an StandardBackedAccountService
        verify(configurationRequirements: account.configuration, against: accountService)
    }

    @MainActor
    private func verify(
        configurationRequirements configuration: AccountValueConfiguration,
        against service: Service
    ) {
        logger.debug("Checking \(service.description) against the configured account keys.")

        // if account service states exact supported keys, AccountIdKey must be one of them
        if case let .exactly(keys) = service.configuration.supportedAccountKeys {
            precondition(
                keys.contains(AccountKeys.accountId),
                """
                The account service \(type(of: service)) doesn't have the \\.accountId configured \
                as an supported key. \
                A primary, unique and stable user identifier is expected with most SpeziAccount components and \
                will result in those components breaking.
                """
            )
        }

        // collect all values that cannot be handled by the account service
        let unmappedAccountKeys: [any AccountKeyConfiguration] = service.configuration
            .unsupportedAccountKeys(basedOn: configuration)

        guard !unmappedAccountKeys.isEmpty else {
            return // we are fine, nothing unsupported
        }


        if let storageProvider = storageProvider.first {
            // we are also fine, we have a standard that can store any unsupported account values
            logger.debug("""
                         The storage provider \(type(of: storageProvider)) is used to store the following account values that \
                         are unsupported by the Account Service \(service.description): \(unmappedAccountKeys.debugDescription).
                         """)
            return
        }

        // When we reach here, we have no way to store the configured account value
        // Note: AnyAccountValueConfigurationEntry has a nice `debugDescription` that pretty prints the KeyPath property name
        preconditionFailure(
            """
            Your `AccountConfiguration` lists the following account values "\(unmappedAccountKeys.debugDescription)" which are
            not supported by the Account Service \(service.description)!

            The Account Service \(service.description) indicated that it cannot store the above-listed account values.

            In order to proceed you may use a Standard inside your Spezi Configuration that conforms to \
            `AccountStorageConstraint` which handles storage of the above-listed account values. Otherwise, you may \
            remove the above-listed account values from your SpeziAccount configuration.
            """
        )
    }
}


extension AccountConfiguration: Module {}
