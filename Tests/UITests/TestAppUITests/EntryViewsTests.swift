//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class EntryViewsTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testEntryViews() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        XCTAssertTrue(app.buttons["Entry Views"].exists)
        app.buttons["Entry Views"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Entry Views"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.navigationBars.buttons["Dismiss"].exists)

        XCTAssertTrue(app.staticTexts["Bool Value, false"].exists)
        XCTAssertTrue(app.switches["Toggle"].exists)
        XCTAssertEqual(app.switches["Toggle"].value as? String, "0")
        app.switches["Toggle"].coordinate(withNormalizedOffset: .init(dx: 0.9, dy: 0.5)).tap()
        XCTAssertTrue(app.staticTexts["Bool Value, true"].waitForExistence(timeout: 0.5))
        app.switches["Toggle"].coordinate(withNormalizedOffset: .init(dx: 0.9, dy: 0.5)).tap()
        XCTAssertTrue(app.staticTexts["Bool Value, false"].waitForExistence(timeout: 0.5))


        XCTAssertTrue(app.staticTexts["Integer Value, 0"].exists)
        XCTAssertTrue(app.textFields["Numeric Key"].exists)
        // ensure empty value is translated to empty string (placeholder value) and not zero
        XCTAssertEqual(app.textFields["Numeric Key"].value as? String, "Numeric Key")
        try app.textFields["Numeric Key"].enter(value: "1234", dismissKeyboard: false)
        XCTAssertTrue(app.staticTexts["Integer Value, 1234"].waitForExistence(timeout: 0.5))
        app.typeText("a")
        XCTAssertTrue(app.staticTexts["The input can only consist of digits."].waitForExistence(timeout: 2.0))
        app.typeText(XCUIKeyboardKey.delete.rawValue)
        app.navigationBars.buttons["Dismiss"].tap() // dismisses the keyboard (workaround for numpad keyboard)


        XCTAssertTrue(app.staticTexts["Double Value, 1.5"].exists)
        XCTAssertTrue(app.textFields["Double Key"].exists)
        XCTAssertEqual(app.textFields["Double Key"].value as? String, "1.5")

        try app.textFields["Double Key"].delete(count: 3, dismissKeyboard: false)
        XCTAssertTrue(app.staticTexts["Double Value, 0"].exists)
        app.typeText("23.5")
        XCTAssertTrue(app.staticTexts["Double Value, 23.5"].waitForExistence(timeout: 2.0))
        app.typeText("a")
        app.navigationBars.buttons["Dismiss"].tap() // dismisses the keyboard (workaround for numpad keyboard)
        XCTAssertTrue(app.staticTexts["The input can only consist of digits."].waitForExistence(timeout: 2.0))
    }
}
