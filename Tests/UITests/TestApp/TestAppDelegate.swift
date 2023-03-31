//
// This source file is part of the TemplatePackage open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKit


class TestAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: TestAppStandard()) {
            TestAccountConfiguration()
        }
    }
}
