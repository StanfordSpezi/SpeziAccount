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


class TestAppDelegate: SpeziAppDelegate {
    let features: Features = {
        do {
            let features = try Features.parse()
            return features
        } catch {
            print("Error: \(error)")
            print("Verify the supplied command line arguments: " + ProcessInfo.processInfo.arguments.dropFirst().joined(separator: " "))
            print(Features.helpMessage())
            return Features()
        }
    }()

    var configuredValues: AccountValueConfiguration {
        switch features.configurationType {
        case .default:
            return [
                .requires(\.userId),
                .collects(\.name),
                .collects(\.genderIdentity),
                .collects(\.dateOfBirth),
                .supports(\.biography)
            ]
        case .allRequired:
            return [
                .requires(\.userId),
                .requires(\.name),
                .requires(\.genderIdentity),
                .requires(\.dateOfBirth),
                .supports(\.biography) // that's special case for checking follow up info on e.g. login
            ]
        case .allRequiredWithBio:
            return [
                .requires(\.userId),
                .requires(\.name),
                .requires(\.genderIdentity),
                .requires(\.dateOfBirth),
                .requires(\.biography)
            ]
        }
    }

    override var configuration: Configuration {
        Configuration(standard: TestStandard()) {
            AccountConfiguration(service: TestAccountService(.emailAddress, features: features), configuration: configuredValues)
        }
    }
}
