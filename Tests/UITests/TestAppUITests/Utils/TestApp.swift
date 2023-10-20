//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


struct TestApp: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    static func launch( // swiftlint:disable:this function_default_parameter_at_end
        serviceType: String = "mail",
        config: String = "default",
        defaultCredentials: Bool = false,
        accountRequired: Bool = false,
        verifyAccountDetails: Bool = false,
        flags: String...
    ) -> TestApp {
        let app = XCUIApplication()
        app.launchArguments = ["--service-type", serviceType, "--configuration-type", config]
            + (defaultCredentials ? ["--default-credentials"] : [])
            + (accountRequired ? ["--account-required-modifier"] : [])
            + (verifyAccountDetails ? ["--verify-required-details"] : [])
            + flags
        app.launch()

        let testApp = TestApp(app: app)
        testApp.verify()
        return testApp
    }

    func verify(timeout: TimeInterval = 1.0) {
        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: timeout))
    }

    func openAccountSetup(timeout: TimeInterval = 1.0) -> TestableAccountSetup {
        tap(button: "Account Setup", timeout: timeout)

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }

    func openAccountOverview(timeout: TimeInterval = 1.0) -> TestableAccountOverview {
        tap(button: "Account Overview", timeout: timeout)

        let overview = TestableAccountOverview(app: app)
        overview.verify()
        return overview
    }
}
