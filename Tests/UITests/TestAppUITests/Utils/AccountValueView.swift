//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


@MainActor
protocol AccountValueView: TestableView {}


extension AccountValueView {
    @available(*, deprecated, message: "Removed")
    func updateGenderIdentity(from: String, to: String) { // TODO: remove
        app.updateGenderIdentity(from: from, to: to)
    }

    @available(*, deprecated, message: "Removed")
    func changeDatePreviousMonthFirstDay() { // TODO: remove
        app.changeDatePreviousMonthFirstDay()
    }
}


extension XCUIApplication {
    func updateGenderIdentity(from: String, to: String, file: StaticString = #filePath, line: UInt = #line) {
        staticTexts[from].tap()
        XCTAssertTrue(buttons[to].waitForExistence(timeout: 0.5), "Couldn't locate gender identity dropdown", file: file, line: line)
        buttons[to].tap()
    }

    func changeDatePreviousMonthFirstDay() {
        // add date button is presented if date is not required or doesn't exists yet
        if buttons["Add Date of Birth"].exists { // uses the accessibility label
            buttons["Add Date of Birth"].tap()
        }

        XCTAssertTrue(datePickers.firstMatch.waitForExistence(timeout: 2.0))
        datePickers.firstMatch.tap()

        // navigate to previous month and select the first date
        XCTAssertTrue(datePickers.buttons["Previous Month"].waitForExistence(timeout: 2.0))
        datePickers.buttons["Previous Month"].tap()

        usleep(500_000)
        datePickers.collectionViews.buttons.element(boundBy: 0).tap()

        // close the date picker again
        staticTexts["Date of Birth"].tap()
    }
}
