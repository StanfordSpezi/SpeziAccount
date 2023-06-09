//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

final class EmptyAccountServicesTests: XCTestCase {

    func testDocumentationHint(forButton: String) throws {
        let app = XCUIApplication()
        app.launchArguments = ["--emptyAccountServices"]
        app.launch()

        app.buttons[forButton].tap()

        XCTAssertTrue(app.buttons["Open Documentation"].waitForExistence(timeout: 6))
        XCTAssertTrue(
            app
                .staticTexts["No Account Services set up.\n Please refer to the documentation of the SpeziAccount package on how to set up an AccountService!"]
                .waitForExistence(timeout: 6.0)
        )
    }

    func testDocumentationHintLogin() throws {
        try testDocumentationHint(forButton: "Login")
    }

    func testDocumentationHintSignup() throws {
        try testDocumentationHint(forButton: "SignUp")
    }
}
