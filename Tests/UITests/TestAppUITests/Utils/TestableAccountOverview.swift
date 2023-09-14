//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


struct TestableAccountOverview: AccountValueView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify(headerText: String = "Account Overview") {
        XCTAssertTrue(app.staticTexts[headerText].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 6.0))
    }
}
