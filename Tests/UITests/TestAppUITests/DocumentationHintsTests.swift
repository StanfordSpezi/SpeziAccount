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
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testDocumentationHint(type: ServiceType, button: String, hint: String) throws {
        let app = XCUIApplication()
        app.launch(serviceType: type)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.buttons[button].tap()

        // Note for the `hint`, you have to escape any ' characters!
        let predicate = NSPredicate(format: "label LIKE '\(hint)'") // hint may be longer than 128 characters.
        XCTAssertTrue(app.staticTexts.element(matching: predicate).exists)

        XCTAssertTrue(app.buttons["Open Documentation"].exists)
        app.buttons["Open Documentation"].tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
#if os(visionOS)
        sleep(3)
#endif
        XCTAssert(safari.wait(for: .runningForeground, timeout: 5))

        #if !os(visionOS) // this assertion is not possible on visionOS
        XCTAssert(safari.textFields["Address"].waitForExistence(timeout: 15))
        let value = try XCTUnwrap(safari.textFields["Address"].value as? String)
        // value start if a left-to-right mark character (0xe2808e) so it won't compare equal and we need to do a contains check
        XCTAssert(value.contains("swiftpackageindex.com, secure"))
        #endif

        safari.terminate()

        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
    }

    @MainActor
    func testEmptyAccountServices() throws {
        try testDocumentationHint(
            type: .empty,
            button: "Account Setup",
            hint: """
                  **No Account Services set up.**\\n\\n\
                  Please refer to the documentation of the SpeziAccount package on how to set up an AccountService!
                  """
        )
    }

    @MainActor
    func testMissingAccount() throws {
        try testDocumentationHint(
            type: .mail,
            button: "Account Overview",
            hint: """
                  **Couldn\\'t find a user account.**\\n\\nThis view requires an active user account.\\n\
                  Refer to the documentation of the AccountSetup view on how to setup a user account!
                  """
        )
    }
}
