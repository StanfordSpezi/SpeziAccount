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
/// ``AccountService`` can either be supplied directly via ``init(_:)-9gza3`` or might be automatically collected from
/// other `Component`s that provide ``AccountService`` instances (like the `SpeziFirebase` framework).
///
/// - Note: For more information on how to provide an ``AccountService`` if you are implementing your own Spezi `Component`
///     refer to the <doc:Creating-your-own-Account-Service> article.
public final class AccountConfiguration: Component, ObservableObjectProvider {
    private let logger = LoggerKey.defaultValue

    private let configuredAccountValues: AccountValueConfiguration // TODO docs
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
    /// - Parameter configuration: TODO docs
    public init(configuration: [ConfiguredAccountValue] = .default) {
        // TODO variadic arguments! once we have those we can remove the intermediate accessor!
        self.configuredAccountValues = AccountValueConfiguration(configuration)
        self.providedAccountServices = []
    }

    /// Initializes a `AccountConfiguration` by directly providing a set of ``AccountService`` instances.
    ///
    /// In addition to the supplied ``AccountService``s, ``SpeziAccount`` will collect any ``AccountService`` instances
    /// provided by other Spezi `Component`s.
    ///
    /// - Parameters:
    ///   - configuration: TODO docs
    ///   - accountServices: Account Services provided through a ``AccountServiceBuilder``.
    public init(
        configuration: [ConfiguredAccountValue] = .default,
        @AccountServiceBuilder _ accountServices: () -> [any AccountService]
    ) {  // TODO variadic arguments!
        self.configuredAccountValues = AccountValueConfiguration(configuration)
        self.providedAccountServices = accountServices()
    }


    public func configure() {
        // assemble the final array of account services
        let accountServices = providedAccountServices + self.accountServices

        for accountService in accountServices {
            // verify that the configuration matches what is expected by the account service
            verifyAccountServiceRequirements(of: accountService)

            // verify account service can store all configured account values
            verifyConfigurationRequirements(against: accountService)
        }

        self.account = Account(services: accountServices, configuration: configuredAccountValues)
    }

    private func verifyAccountServiceRequirements(of service: any AccountService) {
        let requiredValues = service.configuration.requiredAccountValues

        // a collection of AccountKey.Type which aren't configured at all or not configured to be required
        let mismatchedKeys = requiredValues.filter { key in
            // TODO is there a use case to force collection, no right?
            configuredAccountValues[key] == nil
                || (key.isRequired && configuredAccountValues[key]?.requirement != .required) // TODO second is always true currently!
        }

        guard !mismatchedKeys.isEmpty else {
            return
        }

        // TODO the array.description doesn't work here right? how to we access the KeyPath thingy?
        preconditionFailure(
            """
            You configured the AccountService \(service) which requires the following account values to be configured: \
            \(mismatchedKeys.description).

            Please modify your `AccountServiceConfiguration` to have these account values configured.
            """
        )
    }

    private func verifyConfigurationRequirements(against service: any AccountService) {
        let supportedValues = service.configuration.supportedAccountValues

        logger.debug("Checking \(service.description) against the configured account values.")

        // collect all values that cannot be handled by the account service
        let unmappedAccountValues = configuredAccountValues.filter { configuredValue in
            !supportedValues.canStore(configuredValue)
        }

        guard !unmappedAccountValues.isEmpty else {
            return // we are fine, nothing unsupported
        }

        if let accountStorageStandard = standard as? any AccountStorageStandard {
            // we are also fine, we have a standard that can store any unsupported account values
            logger.debug("""
                         The standard \(accountStorageStandard.description) is used to store the following account values that \
                         are unsupported by the Account Service \(service.description): \(unmappedAccountValues.debugDescription)

                         """)
            return
        }

        // when we reach here, we have no way to store the configured account value
        preconditionFailure(
            """
            Your `AccountConfiguration` lists the following account values "\(unmappedAccountValues.debugDescription)" which are
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
