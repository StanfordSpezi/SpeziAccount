//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import SwiftUI


enum AccountServiceType: String, ExpressibleByArgument {
    case mail
    case both
    case withIdentityProvider
    case empty
}


enum AccountValueConfigurationType: String, ExpressibleByArgument {
    case `default`
    case allRequired
    case allRequiredWithBio
}

enum DefaultCredentials: String, ExpressibleByArgument {
    case disabled
    case create
    case createAndSignIn
}


/// A collection of feature flags for the Test App.
struct Features: ParsableArguments, EnvironmentKey {
    static let defaultValue = Features()

    @Option(help: "Define which type of account services are used for the tests.")
    var serviceType: AccountServiceType = .mail

    @Option(help: "Define which type of AccountValueConfiguration is used.")
    var configurationType: AccountValueConfigurationType = .default

    @Option(help: "Control if the app should be populated with default credentials.")
    var credentials: DefaultCredentials = .disabled

    @Flag(help: "Enable the AccountRequiredModifier")
    var accountRequiredModifier = false

    @Flag(help: "Enable the VerifyRequiredAccountDetailsModifier")
    var verifyRequiredDetails = false

    @Flag(help: "Set no name if default credentials are used")
    var noName = false
}


extension EnvironmentValues {
    var features: Features {
        get {
            self[Features.self]
        }
        set {
            self[Features.self] = newValue
        }
    }
}
