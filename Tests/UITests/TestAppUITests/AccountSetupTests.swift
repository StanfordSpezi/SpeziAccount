//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountSetupTests: XCTestCase {
    static var firstSetup = true

    override func setUpWithError() throws {
        guard Self.firstSetup else {
            return
        }
        try super.setUpWithError()

        try disablePasswordAutofill()
        Self.firstSetup = true
    }

    func testEmbeddedViewValidation() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        // check nonEmpty validation
        setup.tapLogin()
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))

        try setup.enter(email: "aa")
        try setup.enter(password: "bb")

        XCTAssertFalse(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 0.5))

        // doing it in reverse order speeds up the input
        try setup.deletePassword(count: 2)
        try setup.deleteEmail(count: 2)

        // validation should not appear if we remove all content via keyboard
        XCTAssertFalse(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 0.5))

        // check nonEmpty validation appears again
        setup.tapLogin()
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))
    }

    func testLoginWithEmail() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        try setup.login(email: Defaults.email, password: Defaults.password.dropLast(3))

        XCTAssertTrue(XCUIApplication().alerts["Credentials do not match"].waitForExistence(timeout: 6.0))
        XCUIApplication().alerts["Credentials do not match"].scrollViews.otherElements.buttons["OK"].tap()

        // retype password
        try setup.deletePassword(count: Defaults.password.dropLast(3).count)
        try setup.enter(password: Defaults.password)

        setup.tapLogin(sleep: 3) // this takes us back to the home screen

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))
    }

    func testAccountSummary() throws {
        let app = TestApp.launch(serviceType: "mail", defaultCredentials: true)
        var setup = app.openAccountSetup()

        XCTAssertTrue(setup.staticTexts[Defaults.name].waitForExistence(timeout: 0.5))
        XCTAssertTrue(setup.staticTexts[Defaults.email].exists)
        XCTAssertTrue(setup.buttons["Logout"].exists)

        setup.tap(button: "Finish")

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))

        setup = app.openAccountSetup()
        XCTAssertTrue(setup.buttons["Logout"].waitForExistence(timeout: 1.0))
        setup.tap(button: "Logout")

        XCTAssertTrue(setup.buttons["Login"].waitForExistence(timeout: 2.0))
    }

    func testLoginWithMultipleServices() throws {
        let app = TestApp.launch(serviceType: "both")
        let setup = app.openAccountSetup()

        setup.tap(button: "Username and Password")

        XCTAssertTrue(setup.buttons["Login"].waitForExistence(timeout: 1.0))

        try setup.login(username: Defaults.username, password: Defaults.password, sleep: 3)

        XCTAssertTrue(app.staticTexts[Defaults.username].waitForExistence(timeout: 2.0))
    }

    func testRestPassword() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        setup.tap(button: "Forgot Password?")

        XCTAssertTrue(setup.staticTexts["Reset Password"].waitForExistence(timeout: 2.0))

        setup.tap(button: "Reset Password")
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))


        // The regular `enter(value:) will hit our "Done" button https://github.com/StanfordBDHG/XCTestExtensions/issues/16
        let keyboard = app.keyboards.firstMatch
        var offset = 0.99
        repeat {
            app.app.coordinate(withNormalizedOffset: CGVector(dx: offset, dy: 0.5)).tap()
            offset -= 0.05
        } while !keyboard.waitForExistence(timeout: 2.0) && offset > 0
        app.app.typeText(Defaults.email)

        setup.tap(button: "Reset Password")

        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 6.0))

        setup.tap(button: "Done")
        XCTAssertFalse(setup.staticTexts["Reset Password"].waitForExistence(timeout: 0.5))

        setup.tap(button: "Close") // TODO type that?

        XCTAssertFalse(setup.staticTexts["Your Account"].waitForExistence(timeout: 0.5))
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
        overview.verifyExistence(text: "LS")
        overview.verifyExistence(text: "Leland Stanford")
        overview.verifyExistence(text: "lelandstanford2@stanford.edu")
        overview.verifyExistence(text: "Gender Identity")
        overview.verifyExistence(text: "Male")
        overview.verifyExistence(text: "Date of Birth")
    }

    func testRequirementLevelsSignup() throws {
        // TODO the same with all required
        let app = TestApp.launch(serviceType: "mail")
        let signupView = app
            .openAccountSetup()
            .openSignup()

        signupView.verifyExistence(textField: "E-Mail Address")
        signupView.verifyExistence(secureField: "Password")
        signupView.verifyExistence(text: "First Name")
        signupView.verifyExistence(text: "Last Name")
        signupView.verifyExistence(text: "Gender Identity")
        signupView.verifyExistence(text: "Date of Birth")
    }

    func testRequirementLevelsOverview() throws {
        let app = TestApp.launch(serviceType: "mail", defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.verifyExistence(text: "Leland Stanford")
        overview.verifyExistence(text: "lelandstanford@stanford.edu")

        overview.verifyExistence(text: "Name, E-Mail Address")
        overview.verifyExistence(text: "Password & Security")

        overview.verifyExistence(text: "Gender Identity")
        overview.verifyExistence(text: "Male")

        overview.verifyExistence(text: "Date of Birth")
        overview.verifyExistence(text: "Mar 9, 1824")
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
