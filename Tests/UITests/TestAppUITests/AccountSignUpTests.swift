//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountSignUpTests: XCTestCase {
    static var firstSetup = true

    override func setUpWithError() throws {
        guard Self.firstSetup else {
            return
        }
        try super.setUpWithError()

        try disablePasswordAutofill()
        Self.firstSetup = true
    }

    func testSignupCredentialsValidation() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        let email = "new-adventure@stanford.edu"
        let password = "123456789"

        XCTAssertTrue(setup.staticTexts["Don't have an Account yet?"].waitForExistence(timeout: 2.0))

        let signupView = setup.openSignup()

        // verify basic validation
        signupView.signup()
        XCTAssertEqual(signupView.staticTexts.matching(identifier: "This field cannot be empty.").count, 2)

        // enter email with validation
        try signupView.enter(email: email.dropLast(13))
        XCTAssertTrue(signupView.staticTexts["The entered email is invalid."].waitForExistence(timeout: 2.0))
        signupView.app.typeText(String(email.dropFirst(13)))

        // enter password with validation
        try signupView.enter(password: password.dropLast(5))
        XCTAssertTrue(signupView.staticTexts["Your password must be at least 8 characters long."].waitForExistence(timeout: 2.0))
        signupView.app.typeText(String(password.dropFirst(4)))

        signupView.signup(sleep: 3) // we will be back at the start page now

        // Now verify what we entered
        let overview = app.openAccountOverview(timeout: 6.0)

        // basic verification of all information recorded
        XCTAssertTrue(overview.staticTexts[email].waitForExistence(timeout: 2.0))
        XCTAssertTrue(overview.staticTexts["Gender Identity"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(overview.staticTexts["Choose not to answer"].waitForExistence(timeout: 0.5))
        // TODO test image present!
    }

    func testInvalidCredentials() throws {
        let app = TestApp.launch(serviceType: "mail")

        let signupView = app
            .openAccountSetup()
            .openSignup()

        try signupView.fillForm(email: Defaults.email, password: Defaults.password)

        signupView.signup(sleep: 1)

        XCTAssertTrue(app.alerts["User Identifier is already taken"].waitForExistence(timeout: 10.0))
        app.alerts["User Identifier is already taken"].scrollViews.otherElements.buttons["OK"].tap()
    }

    func testFullSignup() throws {
        let app = TestApp.launch(serviceType: "mail")
        let signupView = app
            .openAccountSetup()
            .openSignup()

        try signupView.fillForm(
            email: "lelandstanford2@stanford.edu",
            password: Defaults.password,
            name: .init("Leland Stanford"),
            genderIdentity: "Male",
            supplyDateOfBirth: true
        )

        signupView.signup(sleep: 3)

        // Now verify what we entered
        let overview = app.openAccountOverview(timeout: 6.0)

        // verify all the details
        overview.verify(text: "LS")
        overview.verify(text: "Leland Stanford")
        overview.verify(text: "lelandstanford2@stanford.edu")
        overview.verify(text: "Gender Identity")
        overview.verify(text: "Male")
        overview.verify(text: "Date of Birth")
    }

    // TODO test after deleting name that it won't get saved empty! => and that the image is shown!

    // TODO test that required name works! (validation!)

    // TODO overview tests: test collected vs supports.
    //  - name change and userId change
    //  - password change sheet! + password change!

    // TODO merge logijn and signup tests=> AccountSetup tests
    //  - test with an identity provider

    // TODO test the storage standard thingy!
}
