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


final class AccountSetupTests: XCTestCase { // swiftlint:disable:this type_body_length
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
    }

    @MainActor
    func testEmbeddedViewValidation() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        // check fields are not valid
        XCTAssertTrue(app.buttons["Login"].exists)
        XCTAssertTrue(!app.buttons["Login"].isEnabled)

        XCTAssertTrue(app.textFields["E-Mail Address"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        try app.textFields["E-Mail Address"].enter(value: "aa")
        XCTAssertFalse(app.buttons["Login"].isEnabled)
        try app.secureTextFields["Password"].enter(value: "bb")

        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Login"].isEnabled)

        // doing it in reverse order speeds up the input
        try app.secureTextFields["Password"].delete(count: 2)
        try app.textFields["E-Mail Address"].delete(count: 2)

        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.buttons["Login"].isEnabled)
    }

    @MainActor
    func testLoginWithEmail() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail, credentials: .create)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        try app.login(email: Defaults.email, password: Defaults.password.dropLast(3))

        XCTAssertTrue(app.alerts["Credentials do not match"].waitForExistence(timeout: 6.0))
        app.alerts["Credentials do not match"].scrollViews.otherElements.buttons["OK"].tap()

        // retype password
        try app.secureTextFields["Password"].delete(count: Defaults.password.dropLast(3).count, options: .disableKeyboardDismiss)
        try app.secureTextFields["Password"].enter(value: Defaults.password, options: .skipTextFieldSelection)

        // this takes us back to the home screen
        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 0.5)) // might need time to to get enabled
        XCTAssertTrue(app.buttons["Login"].isEnabled)
        app.buttons["Login"].tap()

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testAccountSummary() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail, credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        XCTAssertTrue(app.staticTexts[Defaults.name].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts[Defaults.email].exists)
        XCTAssertTrue(app.buttons["Logout"].exists)
        XCTAssertTrue(app.buttons["Finish"].exists)
        app.buttons["Finish"].tap()

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))

        app.openAccountSetup()
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 1.0))
        app.buttons["Logout"].tap()

        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testSignupWithAnonymousAccount() throws { // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        app.launch(serviceType: .both, config: .allRequired)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        XCTAssertTrue(app.buttons["Stanford SUNet"].exists)
        app.buttons["Stanford SUNet"].tap()

        XCTAssertTrue(app.buttons["Close"].exists)
        app.buttons["Close"].tap()

        XCTAssertTrue(app.staticTexts["User Id, Anonymous"].waitForExistence(timeout: 2.0))

        // TEST if we can modify anonymous details

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Name"].exists)
        XCTAssertFalse(app.staticTexts["Name, E-Mail Address"].exists)
        XCTAssertFalse(app.staticTexts["Sign-In & Security"].exists)

        app.buttons["Name"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Name"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Add Name"].exists)
        app.buttons["Add Name"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Name"].waitForExistence(timeout: 2.0))


        XCTAssertTrue(app.textFields["enter first name"].exists)
        XCTAssertTrue(app.textFields["enter last name"].exists)
        try app.textFields["enter first name"].enter(value: "Leland")
        try app.textFields["enter last name"].enter(value: "Stanford")


        app.navigationBars.buttons["Done"].tap()


        XCTAssertTrue(app.staticTexts["Name, Leland Stanford"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.navigationBars.buttons["Account Overview"].exists)
        app.navigationBars.buttons["Account Overview"].tap()

        XCTAssertTrue(app.navigationBars.buttons["Close"].exists)
        app.navigationBars.buttons["Close"].tap()

        // TEST SIGNUP

        app.openAccountSetup()
        app.openSignup()

        XCTAssertFalse(app.textFields["enter first name"].exists)
        XCTAssertFalse(app.textFields["enter last name"].exists)

#if !os(visionOS)
        let supplyDateOfBirth = true
#else
        // we are not able to interact with the date picker on visionOS
        let supplyDateOfBirth = false
#endif

        try app.fillSignupForm(
            email: Defaults.email,
            password: Defaults.password,
            genderIdentity: "Male",
            supplyDateOfBirth: supplyDateOfBirth
        )

#if os(visionOS)
        app.scrollUpInSignupForm()
#endif

        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        app.collectionViews.buttons["Signup"].tap()

        // important: if the sheet isn't dismissed it may indicate that the completion closure of the AccountSetup view
        // is no longer getting called. This is implicitly tested here.

        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Account Id, Stable"].exists)
        XCTAssertFalse(app.staticTexts["User Id, Anonymous"].exists)
    }

    @MainActor
    func testBasicIdentityProviderLayout() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .withIdentityProvider)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        XCTAssertTrue(app.buttons["Login"].exists)
        XCTAssertTrue(app.staticTexts["or"].exists) // divider
        XCTAssertTrue(app.buttons["Sign in with Apple"].exists)
    }

    @MainActor
    func testResetPassword() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        XCTAssertTrue(app.buttons["Forgot Password?"].exists)
        app.buttons["Forgot Password?"].tap()

        XCTAssertTrue(app.staticTexts["Reset Password"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.buttons["Reset Password"].exists)
        app.buttons["Reset Password"].tap()
        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))

        // field should already have focus, due to pressing the button
        app.typeText(Defaults.email)

        app.buttons["Reset Password"].tap()

        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 3.0))

        XCTAssertTrue(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()

        XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout: 2.0))
        app.buttons["Close"].tap()

        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testSignupCredentialsValidation() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        XCTAssertTrue(app.staticTexts["Don't have an Account yet?"].exists)

        app.openSignup()

        XCTAssertFalse(app.staticTexts["This field cannot be empty."].exists)

        // verify empty validation appearing
        try app.collectionViews.textFields["E-Mail Address"].enter(value: "a", options: .disableKeyboardDismiss)
        try app.collectionViews.textFields["E-Mail Address"].delete(count: 1, options: .skipTextFieldSelection)

        try app.collectionViews.secureTextFields["Password"].enter(value: "a", options: .disableKeyboardDismiss)
        try app.collectionViews.secureTextFields["Password"].delete(count: 1, options: .skipTextFieldSelection)

        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 2.0))
        XCTAssertEqual(app.staticTexts.matching(identifier: "This field cannot be empty.").count, 2)

        // not sure why, but text-field selection has issues due to the presented validation messages, so we exit a reenter to resolve this
        try app.closeSignupForm()
        app.openSignup()

        let email = "new-adventure@stanford.edu"
        let password = "123456789"

        // enter email with validation
        try app.collectionViews.textFields["E-Mail Address"].enter(value: String(email.dropLast(13)), options: .disableKeyboardDismiss)
        XCTAssertTrue(app.staticTexts["The provided email is invalid."].waitForExistence(timeout: 2.0))
        try app.collectionViews.textFields["E-Mail Address"].enter(value: String(email.dropFirst(13)), options: .skipTextFieldSelection)

        // enter password with validation
        try app.collectionViews.secureTextFields["Password"].enter(value: String(password.dropLast(5)), options: .disableKeyboardDismiss)
        XCTAssertTrue(app.staticTexts["Your password must be at least 8 characters long."].waitForExistence(timeout: 2.0))
        try app.collectionViews.secureTextFields["Password"].enter(value: String(password.dropFirst(4)), options: .skipTextFieldSelection)

#if os(visionOS)
        app.scrollUpInSignupForm()
#endif

        // we access the signup button through the collectionView as there is another signup button behind the signup sheet.
        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 2.0))
        app.collectionViews.buttons["Signup"].tap()

        XCTAssertTrue(app.staticTexts[email].waitForExistence(timeout: 4.0))

        // Now verify what we entered
        app.openAccountOverview()

        // basic verification of all information recorded
        XCTAssertTrue(app.staticTexts[email].exists)
        XCTAssertTrue(app.staticTexts["Gender Identity, Choose not to answer"].exists)
    }

    @MainActor
    func testNameValidation() throws {
        let app = XCUIApplication()
        app.launch(config: .allRequired)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()
        app.openSignup()

#if os(visionOS)
        app.scrollUpInSignupForm()
#endif

        XCTAssertTrue(app.collectionViews.buttons["Signup"].exists)
        XCTAssertFalse(app.collectionViews.buttons["Signup"].isEnabled)

        try app.textFields["enter first name"].enter(value: "a", options: .disableKeyboardDismiss)
        try app.textFields["enter first name"].delete(count: 1, options: .skipTextFieldSelection)

        XCTAssertTrue(app.staticTexts["This field cannot be empty."].waitForExistence(timeout: 1.0))

        try app.textFields["enter last name"].enter(value: "a", options: .disableKeyboardDismiss)
        try app.textFields["enter last name"].delete(count: 1, options: .skipTextFieldSelection)

        XCTAssertEqual(app.staticTexts.matching(identifier: "This field cannot be empty.").count, 2)
    }

    @MainActor
    func testInvalidCredentials() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail, credentials: .create)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()
        app.openSignup()

        try app.fillSignupForm(email: Defaults.email, password: Defaults.password)

#if os(visionOS)
        app.scrollUpInSignupForm()
#endif

        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        app.collectionViews.buttons["Signup"].tap()

        XCTAssertTrue(app.alerts["User Identifier is already taken"].waitForExistence(timeout: 10.0))
        app.alerts["User Identifier is already taken"].scrollViews.otherElements.buttons["OK"].tap()
    }

    @MainActor
    func testFullSignup() throws {
        let app = XCUIApplication()
        app.launch(serviceType: .mail)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()
        app.openSignup()

#if !os(visionOS)
        // we do that check later
        XCTAssertTrue(app.buttons["Add Date of Birth"].waitForExistence(timeout: 0.5)) // test requirement level

        let supplyDateOfBirth = true
#else
        // we are not able to interact with the date picker on visionOS
        let supplyDateOfBirth = false
#endif


        try app.fillSignupForm(
            email: "lelandstanford2@stanford.edu",
            password: Defaults.password,
            name: .init("Leland Stanford"),
            genderIdentity: "Male",
            supplyDateOfBirth: supplyDateOfBirth
        )

#if os(visionOS)
        XCTAssertTrue(app.buttons["Add Date of Birth"].waitForExistence(timeout: 0.5)) // test requirement level
#endif

        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        app.collectionViews.buttons["Signup"].tap()

        XCTAssertTrue(app.staticTexts["lelandstanford2@stanford.edu"].waitForExistence(timeout: 3.0))

        // Note, if we are not back at the home screen, the setup closure does not work

        // Now verify what we entered
        app.openAccountOverview()

        // verify all the details
        XCTAssertTrue(app.staticTexts["LS"].exists)
        XCTAssertTrue(app.staticTexts["Leland Stanford"].exists)
        XCTAssertTrue(app.staticTexts["lelandstanford2@stanford.edu"].exists)
        XCTAssertTrue(app.staticTexts["Gender Identity, Male"].exists)
#if !os(visionOS)
        XCTAssertTrue(app.staticTexts["Date of Birth"].exists)
#endif
    }

    @MainActor
    func testFullSignupWithAdditionalStorage() throws {
        let app = XCUIApplication()
        app.launch(config: .allRequiredWithBio)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()
        app.openSignup()

#if !os(visionOS)
        let supplyDateOfBirth = true
#else
        // we are not able to interact with the date picker on visionOS
        let supplyDateOfBirth = false
#endif

        try app.fillSignupForm(
            email: "lelandstanford2@stanford.edu",
            password: Defaults.password,
            name: .init("Leland Stanford"),
            genderIdentity: "Male",
            supplyDateOfBirth: supplyDateOfBirth,
            biography: "Hello Stanford"
        )

        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        XCTAssertTrue(app.collectionViews.buttons["Signup"].isEnabled)
        app.collectionViews.buttons["Signup"].tap()

        XCTAssertTrue(app.staticTexts["lelandstanford2@stanford.edu"].waitForExistence(timeout: 3.0))

        // Now verify what we entered
        app.openAccountOverview()

        // verify all the details
        XCTAssertTrue(app.staticTexts["LS"].exists)
        XCTAssertTrue(app.staticTexts["Leland Stanford"].exists)
        XCTAssertTrue(app.staticTexts["lelandstanford2@stanford.edu"].exists)
        XCTAssertTrue(app.staticTexts["Gender Identity, Male"].exists)
#if !os(visionOS)
        XCTAssertTrue(app.staticTexts["Date of Birth"].exists)
#endif
        XCTAssertTrue(app.staticTexts["Biography, Hello Stanford"].exists)
    }

    @MainActor
    func testNameEmptinessCheck() throws {
        // if we type in the name in the signup view but then remove all text input then (empty strings in the text fields)
        // we shouldn't save a empty name but instead save no name at all
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()
        app.openSignup()

        let email = "lelandstanford2@stanford.edu"

        try app.fillSignupForm(email: email, password: "123456789", name: .init(givenName: "Leland"))

        try app.textFields["enter first name"].delete(count: 6)

#if os(visionOS)
        app.scrollUpInSignupForm()
#endif

        XCTAssertTrue(app.collectionViews.buttons["Signup"].waitForExistence(timeout: 1.0))
        app.collectionViews.buttons["Signup"].tap()
        XCTAssertTrue(app.staticTexts[email].waitForExistence(timeout: 3.0))

        app.openAccountOverview()

        // basic verification of all information recorded
        XCTAssertTrue(app.staticTexts["Gender Identity, Choose not to answer"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts[email].exists)

        XCTAssertTrue(app.buttons["Name, E-Mail Address"].exists)
        app.buttons["Name, E-Mail Address"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 3.0))

        XCTAssertTrue(app.staticTexts["E-Mail Address, \(email)"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["Leland"].exists)
        XCTAssertTrue(app.staticTexts["Add Name"].exists)
    }

    @MainActor
    func testAdditionalInfoAfterLogin() throws {
        let app = XCUIApplication()
        app.launch(config: .allRequiredWithBio, credentials: .create)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        try app.login(email: Defaults.email, password: Defaults.password)

        // verify the finish account setup view is popping up
        XCTAssertTrue(app.staticTexts["Finish Account Setup"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Please fill out the details below to complete your account setup."].exists)

        try app.textFields["Biography"].enter(value: "Hello Stanford2")

        XCTAssertTrue(app.buttons["Complete"].waitForExistence(timeout: 2.0))
        app.buttons["Complete"].tap()

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))

        app.openAccountOverview()
        XCTAssertTrue(app.staticTexts["Biography, Hello Stanford2"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testLoginWithAdditionalStorage() throws {
        // Ensure AccountSetup properly handles the `incomplete` flag
        // https://github.com/StanfordSpezi/SpeziAccount/pull/79

        let app = XCUIApplication()
        app.launch(config: .default, credentials: .create, includeInvitationCode: true)


        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountSetup()

        try app.login(email: Defaults.email, password: Defaults.password)

        // make sure our incomplete error never pops up
        XCTAssert(app.alerts["Error"].waitForNonExistence(timeout: 5.0))

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testAccountRequiredModifier() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn, accountRequired: true)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        XCTAssertTrue(app.buttons["Account Logout"].exists)
        app.buttons["Account Logout"].tap()

        XCTAssertTrue(app.staticTexts["Your Account"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testVerifyRequiredAccountDetailsModifier() throws {
        let app = XCUIApplication()
        app.launch(config: .allRequiredWithBio, credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Finish Account Setup"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(app.navigationBars.buttons["Cancel"].exists)

        app.staticTexts["Finish Account Setup"].firstMatch.swipeDown(velocity: .slow) // check that this is not dismissible

        app.navigationBars.buttons["Cancel"].tap()

        let confirmation = "This account information is required. If you abort, you will automatically be signed out!"
        XCTAssertTrue(app.staticTexts[confirmation].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.scrollViews.buttons["Logout"].exists)
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 {
            // No cancel button displayed in iOS 26
        } else {
            XCTAssertTrue(app.buttons["Keep Editing"].exists)
        }

        app.scrollViews.buttons["Logout"].tap()

        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["User Id"].exists)
    }
}


// swiftlint:disable:this file_length
