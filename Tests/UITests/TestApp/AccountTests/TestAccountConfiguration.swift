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
            accountServices = [TestAccountService(.emailAddress)]
        case .both:
            accountServices = [
                TestAccountService(.emailAddress),
                TestAccountService(.username)
            ]
        case .bothWithIdentityProvider:
            accountServices = [
                TestAccountService(.emailAddress),
                TestAccountService(.username)
                // TODO how to access mock sign in with apple?
            ]
        case .empty:
            accountServices = []
        }
    }
}
