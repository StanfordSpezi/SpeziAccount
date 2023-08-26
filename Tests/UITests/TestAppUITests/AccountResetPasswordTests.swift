//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountResetPasswordTests: XCTestCase {
    func testRestPassword() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        setup.tap(button: "Forgot Password?")

        XCTAssertTrue(setup.staticTexts["Reset Password"].waitForExistence(timeout: 2.0))

        setup.tap(button: "Reset Password")
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))


        // The regular `enter(value:) will hit our "Done" button https://github.com/StanfordBDHG/XCTestExtensions/issues/16
        let keyboard = app.keyboards.firstMatch
        var offset = 0.99
        repeat {
            app.app.coordinate(withNormalizedOffset: CGVector(dx: offset, dy: 0.5)).tap()
            offset -= 0.05
        } while !keyboard.waitForExistence(timeout: 2.0) && offset > 0
        app.app.typeText(Defaults.email)

        setup.tap(button: "Reset Password")

        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 6.0))

        setup.tap(button: "Done")
        XCTAssertFalse(setup.staticTexts["Reset Password"].waitForExistence(timeout: 0.5))

        setup.tap(button: "Close")

        XCTAssertFalse(setup.staticTexts["Your Account"].waitForExistence(timeout: 0.5))
    }
}
