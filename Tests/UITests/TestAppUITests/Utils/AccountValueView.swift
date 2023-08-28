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
        if app.buttons["Add Date"].exists {
            app.buttons["Add Date"].tap()
        }
        app.datePickers.firstMatch.tap()

        // navigate to previous month and select the first date
        app.datePickers.buttons["Previous Month"].tap()
        app.datePickers.collectionViews.buttons.element(boundBy: 0).tap()

        // close the date picker again
        app.staticTexts["Date of Birth"].tap()
    }
}
