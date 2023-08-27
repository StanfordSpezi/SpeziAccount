//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation
import Spezi
import SpeziAccount


final class TestAccountConfiguration: Component {
    @Provide var accountServices: [any AccountService]

    init(features: Features) {
        switch features.serviceType {
        case .mail:
            accountServices = [TestAccountService(.emailAddress, defaultAccount: features.defaultCredentials)]
        case .both:
            accountServices = [
                TestAccountService(.emailAddress, defaultAccount: features.defaultCredentials),
                TestAccountService(.username)
            ]
        case .bothWithIdentityProvider:
            accountServices = [
                TestAccountService(.emailAddress, defaultAccount: features.defaultCredentials),
                TestAccountService(.username)
                // TODO how to access mock sign in with apple?
            ]
        case .empty:
            accountServices = []
        }
    }

    func configure() {
        accountServices
            .compactMap { $0 as? TestAccountService }
            .forEach { $0.configure() }
    }
}
