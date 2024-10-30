//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Close the signup form.
    /// - Parameter discardChangesIfAsked: Confirms to discard all changes if attempting to close the signup form while data was already entered.
    public func closeSignupForm(discardChangesIfAsked: Bool = true) throws {
        XCTAssertTrue(navigationBars.buttons["Close"].exists)
        try XCTUnwrap(navigationBars.buttons.matching(identifier: "Close").allElementsBoundByIndex.last).tap()

        if discardChangesIfAsked && staticTexts["Are you sure you want to discard your input?"].waitForExistence(timeout: 2.0) {
            XCTAssertTrue(buttons["Discard Input"].waitForExistence(timeout: 2.0))
            buttons["Discard Input"].tap()
        }
    }
    
    /// Fill out the signup form.
    /// - Parameters:
    ///   - email: The email address to use.
    ///   - password: The password to use.
    ///   - name: Optional name.
    ///   - genderIdentity: Optional gender identity.
    ///   - supplyDateOfBirth: Optional, specify a date of birth. If `true` this makes sure a date of birth is specified. Typically it will select the first day of the previous month.
    public func fillSignupForm(
        email: String,
        password: String,
        name: PersonNameComponents? = nil,
        genderIdentity: String? = nil,
        supplyDateOfBirth: Bool = false
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

#if os(visionOS)
            if genderIdentity != nil || supplyDateOfBirth {
                scrollUpInSignupForm()
            }
#endif
        }

        if let genderIdentity {
            XCTAssertTrue(staticTexts["Choose not to answer"].waitForExistence(timeout: 2.0), "Didn't find Gender Identity Picker")
            self.updateGenderIdentity(from: "Choose not to answer", to: genderIdentity)
        }

        if supplyDateOfBirth {
            self.changeDateOfBirth()
        }
    }
}


extension XCUIApplication {
#if os(visionOS)
    /// Scrolls up in the  `SignupForm` on visionOS platforms.
    public func scrollUpInSignupForm() {
        // swipeUp doesn't work on visionOS, so we improvise

        if staticTexts["Name"].waitForExistence(timeout: 2.0) {
            XCTAssertTrue(staticTexts["Create a new Account"].exists)
            staticTexts["Name"].press(forDuration: 0, thenDragTo: staticTexts["Create a new Account"].firstMatch)
        } else if staticTexts["Personal Details"].exists {
            XCTAssertTrue(staticTexts["Create a new Account"].exists)
            staticTexts["Personal Details"].press(forDuration: 0, thenDragTo: staticTexts["Create a new Account"].firstMatch)
        } else {
            XCTFail("Could not scroll on visionOS")
        }
    }
#endif
}
