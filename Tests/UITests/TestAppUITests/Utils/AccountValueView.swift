//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


protocol AccountValueView: TestableView {}


extension AccountValueView {
    func enter<Input: StringProtocol>(email: Input) throws {
        try enter(field: "E-Mail Address", text: email)
    }

    func enter<Input: StringProtocol>(username: Input) throws {
        try enter(field: "Username", text: username)
    }

    func enter<Input: StringProtocol>(password: Input) throws {
        try enter(secureField: "Password", text: password)
    }

    func deleteEmail(count: Int) throws {
        try delete(field: "E-Mail Address", count: count)
    }

    func deletePassword(count: Int) throws {
        try delete(secureField: "Password", count: count)
    }

    func updateGenderIdentity(from: String, to: String) {
        app.staticTexts[from].tap()
        XCTAssertTrue(app.buttons[to].waitForExistence(timeout: 0.5))
        app.buttons[to].tap()
    }

    func changeDatePreviousMonthFirstDay() {
        // add date button is presented if date is not required or doesn't exists yet
        if app.buttons["Add Date of Birth"].exists { // uses the accessibility label
            app.buttons["Add Date of Birth"].tap()
        }

        XCTAssertTrue(app.datePickers["Date of Birth"].waitForExistence(timeout: 2.0))
        app.datePickers["Date of Birth"].tap()

        // navigate to previous month and select the first date
        XCTAssertTrue(app.datePickers.buttons["Previous Month"].waitForExistence(timeout: 2.0))
        app.datePickers.buttons["Previous Month"].tap()

        usleep(500_000)
        app.datePickers.collectionViews.buttons.element(boundBy: 0).tap()

        // close the date picker again
        app.staticTexts["Date of Birth"].tap()
    }
}
