//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest

enum ServiceType: String {
    case mail
    case both
    case withIdentityProvider
    case empty
}

enum Config: String {
    case `default`
    case allRequired
    case allRequiredWithBio
}


extension XCUIApplication {
    func launch( // swiftlint:disable:this function_default_parameter_at_end
        serviceType: ServiceType = .mail,
        config: Config = .default,
        defaultCredentials: Bool = false,
        accountRequired: Bool = false,
        verifyAccountDetails: Bool = false,
        noName: Bool = false,
        flags: String...
    ) {
        launchArguments = ["--service-type", serviceType.rawValue, "--configuration-type", config.rawValue]
        launchArguments += (defaultCredentials ? ["--default-credentials"] : [])
        launchArguments += (accountRequired ? ["--account-required-modifier"] : [])
        launchArguments += (verifyAccountDetails ? ["--verify-required-details"] : [])
        launchArguments += (noName ? ["--no-name"] : [])
        launchArguments += flags
        launch()
    }

    func openAccountOverview(timeout: TimeInterval = 2.0) {
        XCTAssertTrue(buttons["Account Overview"].waitForExistence(timeout: timeout))
        buttons["Account Overview"].tap()

        XCTAssertTrue(navigationBars.staticTexts["Account Overview"].waitForExistence(timeout: 2.0))
    }

    func openAccountSetup(timeout: TimeInterval = 1.0) {
        XCTAssertTrue(buttons["Account Setup"].waitForExistence(timeout: timeout))
        buttons["Account Setup"].tap()

        XCTAssertTrue(staticTexts["Your Account"].waitForExistence(timeout: 2.0))
    }
}
