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


final class TestAccountConfiguration: Module {
    @Provide var accountServices: [any AccountService]

    @Model var testModel: TestAlertModel

    init(features: Features) {
        let model = TestAlertModel()

        switch features.serviceType {
        case .mail:
            accountServices = [TestAccountService(model, .emailAddress, defaultAccount: features.defaultCredentials, noName: features.noName)]
        case .both:
            accountServices = [
                TestAccountService(model, .emailAddress, defaultAccount: features.defaultCredentials, noName: features.noName),
                TestAccountService(model, .username)
            ]
        case .withIdentityProvider:
            accountServices = [
                TestAccountService(model, .emailAddress, defaultAccount: features.defaultCredentials, noName: features.noName),
                MockSignInWithAppleProvider()
            ]
        case .empty:
            accountServices = []
        }

        testModel = model
    }

    func configure() {
        accountServices
            .compactMap { $0 as? TestAccountService }
            .forEach { $0.configure() }
    }
}
