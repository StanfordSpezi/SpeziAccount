//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTSpeziAccount


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
        supplyDateOfBirth: Bool = false, // swiftlint:disable:this function_default_parameter_at_end
        biography: String
    ) throws {
        try fillSignupForm(email: email, password: password, name: name, genderIdentity: genderIdentity, supplyDateOfBirth: supplyDateOfBirth)

#if os(visionOS)
        if name != nil && genderIdentity == nil && !supplyDateOfBirth {
            scrollUpInSignupForm() // fillSignupForm didn't scroll, so we need to here
        }
#endif

        try textFields["Biography"].enter(value: biography)
    }
}
