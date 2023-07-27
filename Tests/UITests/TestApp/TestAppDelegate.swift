//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            TestAccountConfiguration(emptyAccountServices: FeatureFlags.emptyAccountServices)
        }
    }
}
