//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func closeSignupForm(discardChangesIfAsked: Bool = true) throws {
        XCTAssertTrue(navigationBars.buttons["Close"].exists)
        try XCTUnwrap(navigationBars.buttons.matching(identifier: "Close").allElementsBoundByIndex.last).tap()

        if discardChangesIfAsked && staticTexts["Are you sure you want to discard your input?"].waitForExistence(timeout: 2.0) {
            XCTAssertTrue(buttons["Discard Input"].waitForExistence(timeout: 2.0))
            buttons["Discard Input"].tap()
        }
    }

    func fillSignupForm(
        email: String,
        password: String,
        name: PersonNameComponents? = nil,
        genderIdentity: String? = nil,
        supplyDateOfBirth: Bool = false,
        biography: String? = nil
    ) throws {
        // we access through collectionViews as there is another E-Mail Address and Password field behind the signup sheet
        XCTAssertTrue(collectionViews.textFields["E-Mail Address"].exists, "Couldn't locate E-Mail Address field")
        try collectionViews.textFields["E-Mail Address"].enter(value: email)

        XCTAssertTrue(collectionViews.secureTextFields["Password"].exists, "Couldn't locate Password field")
        try collectionViews.secureTextFields["Password"].enter(value: password)

        if let name {
            if let firstname = name.givenName {
                try textFields["enter first name"].enter(value: firstname)
            }
            if let lastname = name.familyName {
                try textFields["enter last name"].enter(value: lastname)
            }
        }

        if let genderIdentity {
            XCTAssertTrue(staticTexts["Choose not to answer"].waitForExistence(timeout: 2.0), "Didn't find Gender Identity Picker")
            self.updateGenderIdentity(from: "Choose not to answer", to: genderIdentity)
        }

        if supplyDateOfBirth {
            self.changeDatePreviousMonthFirstDay()
        }

        if let biography {
            try textFields["Biography"].enter(value: biography)
        }
    }
}
