//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func openSignup() {
        XCTAssertTrue(buttons["Signup"].waitForExistence(timeout: 3.0))
        buttons["Signup"].tap()

        XCTAssertTrue(staticTexts["Please fill out the details below to create your new account."].waitForExistence(timeout: 3.0))
    }

    func fillSignupForm(
        email: String,
        password: String,
        name: PersonNameComponents? = nil,
        genderIdentity: String? = nil,
        supplyDateOfBirth: Bool = false,
        biography: String
    ) throws {
        fillSignupForm(email: email, password: password, name: name, genderIdentity: genderIdentity, supplyDateOfBirth: supplyDateOfBirth)

        if let biography {
            try textFields["Biography"].enter(value: biography)
        }
    }
}
