//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import SwiftUI


// TODO rename
enum AccountServiceType: String, ExpressibleByArgument {
    case mail
    case both
    case bothWithIdentityProvider
    case empty
}


/// A collection of feature flags for the Test App.
struct Features: ParsableArguments, EnvironmentKey {
    static let defaultValue = Features()

    @Option(help: "Define which type of account services are used for the tests")
    var serviceType: AccountServiceType = .mail
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
