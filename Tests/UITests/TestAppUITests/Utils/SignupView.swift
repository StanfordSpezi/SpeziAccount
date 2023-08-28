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
        try enter(email: email)

        try enter(password: password)

        if let name {
            if let firstname = name.givenName {
                try enter(field: "Enter your first name ...", text: firstname)
            }
            if let lastname = name.familyName {
                try enter(field: "Enter your last name ...", text: lastname)
            }
        }


        // workaround some issues with closing the keyboard
        dismissKeyboardExtended()

        if let genderIdentity {
            self.updateGenderIdentity(from: "Choose not to answer", to: genderIdentity)
        }

        if supplyDateOfBirth {
            self.changeDatePreviousMonthFirstDay()
        }
    }

    func signup(sleep sleepMillis: UInt32 = 0) {
        tap(button: "Signup")
        if sleepMillis > 0 {
            sleep(sleepMillis)
        }
    }

    func tapBack(timeout: TimeInterval = 1.0) -> TestableAccountSetup {
        XCTAssertTrue(app.navigationBars.buttons["Back"].waitForExistence(timeout: timeout))
        app.navigationBars.buttons["Back"].tap()

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }
}
