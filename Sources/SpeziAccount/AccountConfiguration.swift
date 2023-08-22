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
public final class AccountConfiguration: Component, ObservableObjectProvider {
    private let logger = LoggerKey.defaultValue

    /// The user-defined configuration of account values that all user accounts need to support.
    private let configuredAccountKeys: AccountValueConfiguration
    /// An array of ``AccountService``s provided directly in the initializer of the configuration object.
    private let providedAccountServices: [any AccountService]

    private var account: Account?

    @StandardActor private var standard: any Standard

    /// The array of ``AccountService``s provided through other Spezi `Components`.
    @Collect private var accountServices: [any AccountService]


    public var observableObjects: [any ObservableObject] {
        guard let account else {
            preconditionFailure("Tried to access ObservableObjectProvider before \(Self.self).configure() was called")
        }

        return [account]
    }


    /// Initializes a `AccountConfiguration` without directly  providing any ``AccountService`` instances.
    ///
    /// ``AccountService`` instances might be automatically collected from other Spezi `Component`s that provide some.
    ///
    /// - Parameter configuration: The user-defined configuration of account values that all user accounts need to support.
    public init(configuration: [ConfiguredAccountKey] = .default) {
        self.configuredAccountKeys = AccountValueConfiguration(configuration)
        self.providedAccountServices = []
    }

    /// Initializes a `AccountConfiguration` by directly providing a set of ``AccountService`` instances.
    ///
    /// In addition to the supplied ``AccountService``s, ``SpeziAccount`` will collect any ``AccountService`` instances
    /// provided by other Spezi `Component`s.
    ///
    /// - Parameters:
    ///   - configuration: The user-defined configuration of account values that all user accounts need to support.
    ///   - accountServices: Account Services provided through a ``AccountServiceBuilder``.
    public init(
        configuration: [ConfiguredAccountKey] = .default,
        @AccountServiceBuilder _ accountServices: () -> [any AccountService]
    ) {
        self.configuredAccountKeys = AccountValueConfiguration(configuration)
        self.providedAccountServices = accountServices()
    }


    public func configure() {
        // assemble the final array of account services
        let accountServices = (providedAccountServices + self.accountServices).map { service in
            // verify that the configuration matches what is expected by the account service
            verifyAccountServiceRequirements(of: service)

            // Verify account service can store all configured account keys.
            // If applicable, wraps the service into an StandardBackedAccountService
            return verifyConfigurationRequirements(against: service)
        }

        self.account = Account(
            services: accountServices,
            configuration: configuredAccountKeys
        )

        if let accountStandard = standard as? any AccountStorageStandard {
            self.account?.injectWeakAccount(into: accountStandard)
        }
    }

    private func verifyAccountServiceRequirements(of service: any AccountService) {
        let requiredValues = service.configuration.requiredAccountKeys

        // A collection of AccountKey.Type which aren't configured by the user or not configured to be required
        // but the Account Service requires them.
        let mismatchedKeys: [any AccountKeyWithDescription] = requiredValues.filter { keyWithDescription in
            let key = keyWithDescription.key
            let configuration = configuredAccountKeys[key]
            return configuration == nil
                || (key.isRequired && configuration?.requirement != .required)
        }

        guard !mismatchedKeys.isEmpty else {
            return
        }

        // Note: AccountKeyWithDescription has a nice `debugDescription` that pretty prints the KeyPath property name
        preconditionFailure(
            """
            You configured the AccountService \(service) which requires the following account values to be configured: \
            \(mismatchedKeys.description).

            Please modify your `AccountServiceConfiguration` to have these account values configured.
            """
        )
    }

    private func verifyConfigurationRequirements(against service: any AccountService) -> any AccountService {
        logger.debug("Checking \(service.description) against the configured account keys.")

        // collect all values that cannot be handled by the account service
        let unmappedAccountKeys: [any AccountKeyConfiguration] = service.configuration
            .unsupportedAccountKeys(basedOn: configuredAccountKeys)

        guard !unmappedAccountKeys.isEmpty else {
            return service // we are fine, nothing unsupported
        }


        if let accountStandard = standard as? any AccountStorageStandard {
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
            `AccountStorageStandard` which handles storage of the above-listed account values. Otherwise, you may \
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
