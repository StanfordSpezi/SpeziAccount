//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


enum ServiceType: String { // swiftlint:disable:this file_types_order
    case mail
    case both
    case withIdentityProvider
    case empty
}


enum Config: String {
    case `default`
    case allRequired
    case allRequiredWithBio
    case keysWithOptions
    case withSetupView
}

enum DefaultCredentials: String {
    case disabled
    case create
    case createAndSignIn
}


extension XCUIApplication {
    func launch(
        serviceType: ServiceType = .mail,
        config: Config = .default,
        credentials: DefaultCredentials? = nil,
        accountRequired: Bool = false,
        noName: Bool = false,
        includeInvitationCode: Bool = false, // swiftlint:disable:this function_default_parameter_at_end
        flags: String...
    ) {
        launchArguments = ["--service-type", serviceType.rawValue, "--configuration-type", config.rawValue]
        launchArguments += credentials.map { ["--credentials", $0.rawValue] } ?? []
        launchArguments += (accountRequired ? ["--account-required-modifier"] : [])
        launchArguments += (noName ? ["--no-name"] : [])
        launchArguments += (includeInvitationCode ? ["--include-invitation-code"] : [])
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
