//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


struct SignupView: AccountValueView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify() {
        XCTAssertTrue(app.staticTexts["Please fill out the details below to create a new account."].waitForExistence(timeout: 6.0))
    }

    func fillForm(
        email: String,
        password: String,
        name: PersonNameComponents? = nil,
        genderIdentity: String? = nil,
        supplyDateOfBirth: Bool = false
    ) throws {
        // we access through collectionViews as there is another E-Mail Address and Password field behind the signup sheet
        XCTAssertTrue(app.collectionViews.textFields["E-Mail Address"].waitForExistence(timeout: 1.0))
        try app.collectionViews.textFields["E-Mail Address"].enter(value: email)

        XCTAssertTrue(app.collectionViews.secureTextFields["Password"].waitForExistence(timeout: 1.0))
        try app.collectionViews.secureTextFields["Password"].enter(value: password)

        if let name {
            if let firstname = name.givenName {
                try enter(field: "enter first name", text: firstname)
            }
            if let lastname = name.familyName {
                try enter(field: "enter last name", text: lastname)
            }
        }

        if let genderIdentity {
            self.updateGenderIdentity(from: "Choose not to answer", to: genderIdentity)
        }

        if supplyDateOfBirth {
            self.changeDatePreviousMonthFirstDay()
        }
    }

    func signup(sleep sleepMillis: UInt32 = 0) {
        // we access the signup button through the collectionView as there is another signup button behind the signup sheet.
        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        app.collectionViews.buttons["Signup"].tap()

        if sleepMillis > 0 {
            sleep(sleepMillis)
        }
    }

    func tapClose(timeout: TimeInterval = 1.0, discardChangesIfAsked: Bool = true) -> TestableAccountSetup {
        XCTAssertTrue(app.navigationBars["Signup"].buttons["Close"].waitForExistence(timeout: timeout))
        app.navigationBars["Signup"].buttons["Close"].tap()

        if discardChangesIfAsked && app.staticTexts["Are you sure you want to discard your input?"].waitForExistence(timeout: 2.0) {
            tap(button: "Discard Input")
        }

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }
}
