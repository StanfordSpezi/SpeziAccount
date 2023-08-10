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


// TODO docs! everywhere!
public final class AccountConfiguration: Component, ObservableObjectProvider {
    /// The array of ``AccountService``s provided through other Spezi `Components`.
    @Collect
    private var accountServices: [any AccountService]
    /// An array of ``AccountService``s provided directly in the initializer of the configuration object.
    private var providedAccountServices: [any AccountService]

    private var account: Account?

    public var observableObjects: [any ObservableObject] {
        guard let account else {
            preconditionFailure("Tried to access ObservableObjectProvider before \(Self.self).configure() was called")
        }

        return [account]
    }


    public init() {
        self.providedAccountServices = []
    }

    public init(@AccountServiceBuilder _ accountServices: @escaping () -> [any AccountService]) {
        self.providedAccountServices = accountServices()
    }

    public func configure() {
        // assemble the final array of account services
        let accountServices = providedAccountServices + self.accountServices

        self.account = Account(services: accountServices)
    }
}
