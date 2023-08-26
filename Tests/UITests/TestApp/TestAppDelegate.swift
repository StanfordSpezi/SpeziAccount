//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount

class TestAppDelegate: SpeziAppDelegate {
    let features: Features = {
        do {
            let features = try Features.parse()
            print("Parsed command line arguments successfuly")
            return features
        } catch {
            print("Error: \(error)")
            print("Verify the supplied command line arguments: " + CommandLine.arguments.dropFirst().joined(separator: " "))
            print(Features.helpMessage())
            return Features()
        }
    }()

    override var configuration: Configuration {
        Configuration {
            AccountConfiguration(configuration: [
                .requires(\.userId),
                .requires(\.password),
                .collects(\.name),
                .collects(\.genderIdentity),
                .collects(\.dateOfBirth)
            ])
            TestAccountConfiguration(features: features)
        }
    }
}
