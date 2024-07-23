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


/// The Spezi `Component` to configure the ``SpeziAccount`` framework in the `Configuration` section of your app.
///
/// This Spezi `Component` is used to configure the ``SpeziAccount`` framework, namely to collect and setup all ``AccountService``
/// either provided directly or provided by other configured `Component`s. The global ``Account`` object will
/// be injected as an environment object into the view hierarchy of your app.
///
/// ``AccountService`` can either be supplied directly via ``init(configuration:_:)`` or might be automatically collected from
/// other `Component`s that provide ``AccountService`` instances (like the `SpeziFirebase` framework).
///
/// - Note: For more information on how to provide an ``AccountService`` if you are implementing your own Spezi `Component`
///     refer to the <doc:Creating-your-own-Account-Service> article.
public final class AccountConfiguration<Service: AccountService>: Module {
    @Application(\.logger) private var logger
    @Application(\.spezi) private var spezi

    // TODO: find a way to make the @Dependency work again with non-optional but initializer supplied values!
    @Dependency private var account: Account?
    @Dependency private var accountService: Service?

    @StandardActor private var standard: any Standard

    /// Initializes a `AccountConfiguration` by directly providing a set of ``AccountService`` instances.
    ///
    /// In addition to the supplied ``AccountService``s, ``SpeziAccount`` will collect any ``AccountService`` instances
    /// provided by other Spezi `Component`s.
    ///
    /// - Parameters:
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    ///   - accountServices: Account Services provided through a ``AccountServiceBuilder``.
    @MainActor
    public convenience init(
        service: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        self.init(accountService: service, configuration: configuration, defaultActiveDetails: nil)
    }

    /// Configure the Account Module for previewing purposes with default `AccountDetails`.
    ///
    /// - Parameters:
    ///   - builder: The ``AccountDetails`` Builder for the account details that you want to supply.
    ///   - accountService: The ``AccountService`` that is responsible for the supplied account details.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    @_spi(TestingSupport)
    @MainActor
    public convenience init(
        building builder: AccountDetails.Builder,
        active accountService: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        let details = builder.build(owner: accountService)
        self.init(accountService: accountService, configuration: configuration, defaultActiveDetails: details)
    }

    @MainActor
    init(
        accountService: Service,
        configuration: AccountValueConfiguration = .default,
        defaultActiveDetails: AccountDetails? = nil
    ) {
        self._accountService = Dependency(wrappedValue: accountService)

        self._account = Dependency(wrappedValue: Account(
            service: accountService,
            supportedConfiguration: configuration,
            details: defaultActiveDetails
        ))
    }

    public func configure() {
        // assemble the final array of account services
        guard let account else {
            preconditionFailure("Failed to initialize Account module as part of Account configuration.")
        }

        guard let accountService else {
            preconditionFailure("Failed to initialize \(Service.self) module as part of Account configuration.")
        }

        // Verify account service can store all configured account keys.
        // If applicable, wraps the service into an StandardBackedAccountService
        var service = verify(configurationRequirements: account.configuration, against: accountService)

        if let notifyStandard = standard as? any AccountNotifyConstraint {
            service = service.backedBy(standard: notifyStandard)
        }

        account.reconfigureService(service)

        var servicesYetToLoad: [any AccountService] = []
        guard var standardBacked = service as? any _StandardBacked else {
            return
        }
        servicesYetToLoad.append(standardBacked)

        while let nestedBacked = standardBacked.accountService as? any _StandardBacked {
            servicesYetToLoad.append(nestedBacked)
            standardBacked = nestedBacked
        }

        if !servicesYetToLoad.isEmpty {
            Task.detached { @MainActor in
                // we cannot load additional modules within configure() so delay module loading a bit
                for service in servicesYetToLoad {
                    self.spezi.loadModule(service)
                }
            }
        }
    }

    @MainActor
    private func verify(
        configurationRequirements configuration: AccountValueConfiguration,
        against service: Service
    ) -> any AccountService {
        logger.debug("Checking \(service.description) against the configured account keys.")

        // if account service states exact supported keys, AccountIdKey must be one of them
        if case let .exactly(keys) = service.configuration.supportedAccountKeys {
            precondition(
                keys.contains(AccountIdKey.self),
                """
                The account service \(type(of: service)) doesn't have the \\.accountId (aka. AccountIdKey) configured \
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
            return service // we are fine, nothing unsupported
        }


        if let accountStandard = standard as? any AccountStorageConstraint {
            // we are also fine, we have a standard that can store any unsupported account values
            logger.debug("""
                         The standard \(type(of: accountStandard)) is used to store the following account values that \
                         are unsupported by the Account Service \(service.description): \(unmappedAccountKeys.debugDescription)

                         """)
            return service.backedBy(standard: accountStandard)
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
