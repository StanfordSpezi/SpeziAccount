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

    @available(*, deprecated, message: "Use the XCUIApplication extension")
    static func launch( // swiftlint:disable:this function_default_parameter_at_end
        serviceType: String = "mail",
        config: String = "default",
        defaultCredentials: Bool = false,
        accountRequired: Bool = false,
        verifyAccountDetails: Bool = false,
        noName: Bool = false,
        flags: String...
    ) -> TestApp {
        let app = XCUIApplication()
        app.launchArguments += flags
        app.launch(
            serviceType: serviceType,
            config: config,
            defaultCredentials: defaultCredentials,
            accountRequired: accountRequired,
            verifyAccountDetails: verifyAccountDetails,
            noName: noName
        )

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


extension XCUIApplication {
    func launch( // swiftlint:disable:this function_default_parameter_at_end
        serviceType: String = "mail",
        config: String = "default",
        defaultCredentials: Bool = false,
        accountRequired: Bool = false,
        verifyAccountDetails: Bool = false,
        noName: Bool = false,
        flags: String...
    ) {
        launchArguments = ["--service-type", serviceType, "--configuration-type", config]
        launchArguments += (defaultCredentials ? ["--default-credentials"] : [])
        launchArguments += (accountRequired ? ["--account-required-modifier"] : [])
        launchArguments += (verifyAccountDetails ? ["--verify-required-details"] : [])
        launchArguments += (noName ? ["--no-name"] : [])
        launchArguments += flags
        launch()
    }

    func openAccountOverview(timeout: TimeInterval = 1.0, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(buttons["Account Overview"].waitForExistence(timeout: timeout), file: file, line: line)
        buttons["Account Overview"].tap()

        XCTAssertTrue(navigationBars.staticTexts["Account Overview"].waitForExistence(timeout: 2.0), file: file, line: line)
    }
}
