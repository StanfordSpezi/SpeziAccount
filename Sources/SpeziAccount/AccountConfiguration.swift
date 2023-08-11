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
    /// The array of ``AccountService``s provided through other Spezi `Components`.
    @Collect private var accountServices: [any AccountService]
    /// An array of ``AccountService``s provided directly in the initializer of the configuration object.
    private var providedAccountServices: [any AccountService]

    private var account: Account?

    public var observableObjects: [any ObservableObject] {
        guard let account else {
            preconditionFailure("Tried to access ObservableObjectProvider before \(Self.self).configure() was called")
        }

        return [account]
    }


    /// Initializes a `AccountConfiguration` without directly  providing any ``AccountService`` instances.
    ///
    /// ``AccountService`` instances might be automatically collected from other Spezi `Component`s that provide some.
    public init() {
        self.providedAccountServices = []
    }

    /// Initializes a `AccountConfiguration` by directly providing a set of ``AccountService`` instances.
    ///
    /// In addition to the supplied ``AccountService``s, ``SpeziAccount`` will collect any ``AccountService`` instances
    /// provided by other Spezi `Component`s.
    ///
    /// - Parameter accountServices: Account Services provided through a ``AccountServiceBuilder``.
    public init(@AccountServiceBuilder _ accountServices: () -> [any AccountService]) {
        self.providedAccountServices = accountServices()
    }

    public func configure() {
        // assemble the final array of account services
        let accountServices = providedAccountServices + self.accountServices

        self.account = Account(services: accountServices) // TODO pass signup requirements!
    }
}
