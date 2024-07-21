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
public final class AccountConfiguration: Module {
    @Application(\.logger) private var logger
    @Application(\.spezi) private var spezi

    @Dependency private var account: Account?

    @StandardActor private var standard: any Standard

    /// An array of ``AccountService``s provided directly in the initializer of the configuration object.
    @Dependency @ObservationIgnored private var providedAccountServices: [any Module]


    /// Initializes a `AccountConfiguration` without directly  providing any ``AccountService`` instances.
    ///
    /// ``AccountService`` instances might be automatically collected from other Spezi `Component`s that provide some.
    ///
    /// - Parameter configuration: The user-defined configuration of account values that all user accounts need to support.
    public convenience init(configuration: AccountValueConfiguration = .default) {
        self.init(configuration: configuration, defaultActiveDetails: nil) {}
    }

    /// Initializes a `AccountConfiguration` by directly providing a set of ``AccountService`` instances.
    ///
    /// In addition to the supplied ``AccountService``s, ``SpeziAccount`` will collect any ``AccountService`` instances
    /// provided by other Spezi `Component`s.
    ///
    /// - Parameters:
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    ///   - accountServices: Account Services provided through a ``AccountServiceBuilder``.
    public convenience init(
        configuration: AccountValueConfiguration = .default,
        @AccountServiceBuilder _ accountServices: () -> DependencyCollection
    ) {
        self.init(configuration: configuration, defaultActiveDetails: nil, accountServices)
    }

    /// Configure the Account Module for previewing purposes with default `AccountDetails`.
    ///
    /// - Parameters:
    ///   - builder: The ``AccountDetails`` Builder for the account details that you want to supply.
    ///   - accountService: The ``AccountService`` that is responsible for the supplied account details.
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    public convenience init<Service: AccountService>(
        building builder: AccountDetails.Builder,
        active accountService: Service,
        configuration: AccountValueConfiguration = .default
    ) {
        let details = builder.build(owner: accountService)
        self.init(configuration: configuration, defaultActiveDetails: details) {
            accountService
        }
    }

    init(
        configuration: AccountValueConfiguration = .default,
        defaultActiveDetails: AccountDetails? = nil,
        @AccountServiceBuilder _ accountServices: () -> DependencyCollection
    ) {
        self._providedAccountServices = Dependency(using: accountServices())

        self._account = Dependency(wrappedValue: Account(
            services: [],
            supportedConfiguration: configuration,
            details: defaultActiveDetails
        ))
    }

    public func configure() {
        // assemble the final array of account services
        guard let account else {
            preconditionFailure("Failed to initialize Account module as part of Account configuration.")
        }

        let accountServices = (providedAccountServices.compactMap { $0 as? any AccountService }).map { service in
            // Verify account service can store all configured account keys.
            // If applicable, wraps the service into an StandardBackedAccountService
            let service = verify(configurationRequirements: account.configuration, against: service)

            if let notifyStandard = standard as? any AccountNotifyConstraint {
                return service.backedBy(standard: notifyStandard)
            }

            return service
        }

        account.configureServices(accountServices)

        let servicesYetToLoad: [any AccountService] = accountServices.reduce(into: []) { partialResult, service in
            guard var standardBacked = service as? any _StandardBacked else {
                return
            }
            partialResult.append(standardBacked)
            
            while let nestedBacked = standardBacked.accountService as? any _StandardBacked {
                partialResult.append(nestedBacked)
                standardBacked = nestedBacked
            }
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
    private func configureAccountServices() {
        // assemble the final array of account services
        guard let account else {
            preconditionFailure("Failed to initialize Account module as part of Account configuration.")
        }

        let accountServices = (providedAccountServices.compactMap { $0 as? any AccountService }).map { service in
            // Verify account service can store all configured account keys.
            // If applicable, wraps the service into an StandardBackedAccountService
            let service = verify(configurationRequirements: account.configuration, against: service)

            if let notifyStandard = standard as? any AccountNotifyConstraint {
                return service.backedBy(standard: notifyStandard)
            }

            return service
        }

        account.configureServices(accountServices)
    }

    @MainActor
    private func verify(
        configurationRequirements configuration: AccountValueConfiguration,
        against service: any AccountService
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
                         The standard \(accountStandard.description) is used to store the following account values that \
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


extension Standard {
    fileprivate nonisolated var description: String {
        "\(Self.self)"
    }
}
