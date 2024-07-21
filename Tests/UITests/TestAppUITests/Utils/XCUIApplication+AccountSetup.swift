//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func login<Email: StringProtocol, Password: StringProtocol>(email: Email, password: Password) throws {
        try login(userId: email, password: password, field: "E-Mail Address")
    }

    func login<Username: StringProtocol, Password: StringProtocol>(username: Username, password: Password) throws {
        try login(userId: username, password: password, field: "Username")
    }


    private func login<UserId: StringProtocol, Password: StringProtocol>(userId: UserId, password: Password, field: String) throws {
        XCTAssertTrue(textFields[field].exists)
        XCTAssertTrue(secureTextFields["Password"].exists)

        try textFields[field].enter(value: String(userId))
        try secureTextFields["Password"].enter(value: String(password))

        XCTAssertTrue(buttons["Login"].waitForExistence(timeout: 0.5)) // might need time to to get enabled
        XCTAssertTrue(buttons["Login"].isEnabled)
        buttons["Login"].tap()
    }

    func openSignup() {
        XCTAssertTrue(buttons["Signup"].waitForExistence(timeout: 3.0))
        buttons["Signup"].tap()

        XCTAssertTrue(staticTexts["Please fill out the details below to create your new account."].waitForExistence(timeout: 3.0))
    }
}
