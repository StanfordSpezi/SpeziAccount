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
    override func setUpWithError() throws {
        try super.setUpWithError()

        try disablePasswordAutofill()
    }

    func testEmbeddedViewValidation() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        // check fields are not valid
        XCTAssertTrue(setup.buttons["Login"].exists)
        XCTAssertTrue(!setup.buttons["Login"].isEnabled)
        XCTAssertFalse(app.staticTexts["This field cannot be empty."].exists)

        try setup.enter(email: "aa")
        try setup.enter(password: "bb")


        usleep(500_000)
        XCTAssertFalse(app.staticTexts["This field cannot be empty."].exists)

        // doing it in reverse order speeds up the input
        try setup.deletePassword(count: 2)
        try setup.deleteEmail(count: 2)

        // validation should not appear if we remove all content via keyboard
        usleep(500_000)
        XCTAssertFalse(app.staticTexts["This field cannot be empty."].exists)
        XCTAssertTrue(setup.buttons["Login"].exists)
        XCTAssertTrue(!setup.buttons["Login"].isEnabled)
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

    func testBasicIdentityProviderLayout() throws {
        let app = TestApp.launch(serviceType: "withIdentityProvider")
        let setup = app.openAccountSetup()

        XCTAssertTrue(setup.buttons["Login"].waitForExistence(timeout: 0.5))
        setup.verifyExistence(text: "or") // divider
        XCTAssertTrue(setup.buttons["Sign in with Apple"].waitForExistence(timeout: 0.5))
    }

    func testResetPassword() throws {
        let app = TestApp.launch(serviceType: "mail")
        let setup = app.openAccountSetup()

        setup.tap(button: "Forgot Password?")

        XCTAssertTrue(setup.staticTexts["Reset Password"].waitForExistence(timeout: 2.0))

        setup.tap(button: "Reset Password")
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))


        setup.textFields["E-Mail Address"].firstMatch.selectTextField()
        app.app.typeText(Defaults.email)

        setup.tap(button: "Reset Password")

        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 6.0))

        setup.tap(button: "Done")
        XCTAssertFalse(setup.staticTexts["Reset Password"].waitForExistence(timeout: 0.5))

        setup.tap(button: "Close")

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
        XCTAssertTrue(signupView.buttons["Signup"].exists)
        XCTAssertTrue(!signupView.buttons["Signup"].isEnabled)
        XCTAssertFalse(signupView.staticTexts["This field cannot be empty."].exists)

        // verify empty validation appearing
        try signupView.enter(email: "a")
        try signupView.deleteEmail(count: 1)
        try signupView.enter(password: "a")
        try signupView.deletePassword(count: 1)
        XCTAssertEqual(signupView.staticTexts.matching(identifier: "This field cannot be empty.").count, 2)

        // enter email with validation
        try signupView.enter(email: email.dropLast(13))
        XCTAssertTrue(signupView.staticTexts["The provided email is invalid."].waitForExistence(timeout: 2.0))
        try signupView.enter(email: email.dropFirst(13))

        // enter password with validation
        try signupView.enter(password: password.dropLast(5))
        XCTAssertTrue(signupView.staticTexts["Your password must be at least 8 characters long."].waitForExistence(timeout: 2.0))
        try signupView.deletePassword(count: 4) // workaround comparison issue of XCTestExtensions
        try signupView.enter(password: password) // after lost focus, secure fields will erase their content

        signupView.signup(sleep: 3) // we will be back at the start page now

        // Now verify what we entered
        let overview = app.openAccountOverview(timeout: 6.0)

        // basic verification of all information recorded
        XCTAssertTrue(overview.staticTexts[email].waitForExistence(timeout: 2.0))
        XCTAssertTrue(overview.staticTexts["Gender Identity"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(overview.staticTexts["Choose not to answer"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(overview.images["Contact Photo"].waitForExistence(timeout: 0.5)) // verify the header works well without a name
    }

    func testNameValidation() throws {
        let app = TestApp.launch(config: "allRequired")
        let signupView = app
            .openAccountSetup()
            .openSignup(sleep: 3)

        XCTAssertTrue(signupView.buttons["Signup"].exists)
        XCTAssertFalse(signupView.buttons["Signup"].isEnabled)

        try signupView.enter(field: "enter first name", text: "a")
        try signupView.delete(field: "enter first name", count: 1)

        XCTAssertTrue(signupView.staticTexts["The first name field cannot be empty!"].waitForExistence(timeout: 0.5))

        try signupView.enter(field: "enter last name", text: "a")
        try signupView.delete(field: "enter last name", count: 1)

        XCTAssertTrue(signupView.staticTexts["The first name field cannot be empty!"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(signupView.staticTexts["The last name field cannot be empty!"].waitForExistence(timeout: 0.5))
    }

    func testInvalidCredentials() throws {
        let app = TestApp.launch(serviceType: "mail")

        let signupView = app
            .openAccountSetup()
            .openSignup(sleep: 3)

        try signupView.fillForm(email: Defaults.email, password: Defaults.password)

        signupView.signup(sleep: 2)

        XCTAssertTrue(app.alerts["User Identifier is already taken"].waitForExistence(timeout: 10.0))
        app.alerts["User Identifier is already taken"].scrollViews.otherElements.buttons["OK"].tap()
    }

    func testFullSignup() throws {
        let app = TestApp.launch(serviceType: "mail")
        let signupView = app
            .openAccountSetup()
            .openSignup(sleep: 3)

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
        let app = TestApp.launch(serviceType: "mail")
        let signupView = app
            .openAccountSetup()
            .openSignup(sleep: 2)

        signupView.verifyExistence(textField: "E-Mail Address")
        signupView.verifyExistence(secureField: "Password")
        signupView.verifyExistence(text: "First Name")
        signupView.verifyExistence(text: "Last Name")
        signupView.verifyExistence(text: "Gender Identity")
        signupView.verifyExistence(text: "Date of Birth")
    }

    func testNameEmptinessCheck() throws {
        // if we type in the name in the signup view but then remove all text input then (empty strings in the text fields)
        // we shouldn't save a empty name but instead save no name at all
        let app = TestApp.launch()
        let signupView = app
            .openAccountSetup()
            .openSignup(sleep: 2)

        let email = "lelandstanford2@stanford.edu"

        try signupView.enter(email: email)
        try signupView.enter(password: "123456789")

        try signupView.enter(field: "enter first name", text: "Leland")
        try signupView.delete(field: "enter first name", count: 6)

        signupView.signup(sleep: 3)

        // Now verify what we entered
        let overview = app.openAccountOverview(timeout: 6.0)

        // basic verification of all information recorded
        XCTAssertTrue(overview.staticTexts[email].waitForExistence(timeout: 2.0))
        XCTAssertTrue(overview.staticTexts["Gender Identity"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(overview.staticTexts["Choose not to answer"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(overview.images["Contact Photo"].waitForExistence(timeout: 0.5))

        overview.tap(button: "Name, E-Mail Address")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 6.0))

        overview.verifyExistence(text: email)
        XCTAssertFalse(overview.staticTexts["Leland"].waitForExistence(timeout: 1.0))
        overview.verifyExistence(text: "Add Name")
    }
}
