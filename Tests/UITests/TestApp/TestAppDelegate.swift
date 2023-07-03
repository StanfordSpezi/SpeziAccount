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
    override var configuration: Configuration {
        Configuration(standard: TestAppStandard()) {
            AccountConfiguration {
                // TODO just put in the account services?

                TestAccountConfiguration() // TODO FeatureFlags.emptyAccountServices
            }
        }
    }
}
