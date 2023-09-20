//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class DocumentationHintsTests: XCTestCase {
    func testDocumentationHint(type: String, button: String, hint: String) {
        let testApp = TestApp.launch(serviceType: type)
        let app = testApp.app

        app.buttons[button].tap()

        // Note for the `hint`, you have to escape any ' characters!
        let predicate = NSPredicate(format: "label LIKE '\(hint)'") // hint may be longer than 128 characters.
        XCTAssertTrue(app.staticTexts.element(matching: predicate).waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.buttons["Open Documentation"].waitForExistence(timeout: 6))
        app.buttons["Open Documentation"].tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssert(safari.wait(for: .runningForeground, timeout: 10))

        app.activate()
    }

    func testEmptyAccountServices() {
        testDocumentationHint(
            type: "empty",
            button: "Account Setup",
            hint: """
                  **No Account Services set up.**\\n\\n\
                  Please refer to the documentation of the SpeziAccount package on how to set up an AccountService!
                  """
        )
    }

    func testMissingAccount() {
        testDocumentationHint(
            type: "mail",
            button: "Account Overview",
            hint: """
                  **Couldn\\'t find a user account.**\\n\\nThis view requires an active user account.\\n\
                  Refer to the documentation of the AccountSetup view on how to setup a user account!
                  """
        )
    }
}
