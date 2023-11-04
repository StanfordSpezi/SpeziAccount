//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountOverviewTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        try disablePasswordAutofill()
    }

    func testRequirementLevelsOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.verifyExistence(text: "Leland Stanford")
        overview.verifyExistence(text: "lelandstanford@stanford.edu")

        overview.verifyExistence(text: "Name, E-Mail Address")
        overview.verifyExistence(text: "Sign-In & Security")

        overview.verifyExistence(text: "Gender Identity, Male")

        overview.verifyExistence(text: "Date of Birth, Mar 9, 1824")
        
        overview.verifyExistence(text: "License Information")

        XCTAssertTrue(overview.buttons["Logout"].waitForExistence(timeout: 0.5))
    }

    func testEditView() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")

        XCTAssertTrue(overview.buttons["Delete Account"].waitForExistence(timeout: 0.5))

        overview.updateGenderIdentity(from: "Male", to: "Choose not to answer")
        overview.changeDatePreviousMonthFirstDay()

        overview.tap(button: "Add Biography")

        try overview.enter(field: "Biography", text: "Hello Stanford")
        sleep(3)

        overview.tap(button: "Done")

        sleep(3)

        overview.verifyExistence(text: "Choose not to answer")
        overview.verifyExistence(text: "Hello Stanford")
    }

    func testLogout() {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Logout")

        let alert = "Are you sure you want to logout?"
        XCTAssertTrue(XCUIApplication().alerts[alert].waitForExistence(timeout: 6.0))
        XCUIApplication().alerts[alert].scrollViews.otherElements.buttons["Logout"].tap()

        sleep(2)
        app.verify()
        XCTAssertFalse(app.staticTexts["lelandstanford@stanford.edu"].waitForExistence(timeout: 0.5))
    }

    func testAccountRemoval() {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")

        overview.tap(button: "Delete Account")

        let alert = "Are you sure you want to delete your account?"
        XCTAssertTrue(XCUIApplication().alerts[alert].waitForExistence(timeout: 6.0))
        XCUIApplication().alerts[alert].scrollViews.otherElements.buttons["Delete"].tap()

        sleep(2)
        app.verify()

        XCTAssertFalse(app.staticTexts["lelandstanford@stanford.edu"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Got notified about deletion!"].waitForExistence(timeout: 2.0))
    }

    func testEditDiscard() {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")
        sleep(1)

        // no changes, should just leave edit mode
        overview.tap(button: "Cancel")
        XCTAssertTrue(app.buttons["Logout"].waitForExistence(timeout: 2))


        overview.tap(button: "Edit")
        overview.updateGenderIdentity(from: "Male", to: "Choose not to answer")

        overview.tap(button: "Cancel")

        sleep(1)
        let confirmation = "Are you sure you want to discard your changes?"
        overview.verifyExistence(text: confirmation, timeout: 2.0)
        overview.tap(button: "Keep Editing")

        overview.tap(button: "Cancel")
        overview.verifyExistence(text: confirmation, timeout: 2.0)
        overview.tap(button: "Discard Changes")

        overview.verifyExistence(text: "Male") // make sure value didn't change
    }

    func testRemoveDiscard() {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")
        sleep(1)

        // remove image on the list
        let removeButtons = overview.images.matching(identifier: "remove")
        removeButtons.firstMatch.tap()
        overview.buttons["Delete"].tap()

        XCTAssertTrue(overview.buttons["Add Gender Identity"].waitForExistence(timeout: 2.0))

        overview.tap(button: "Cancel")
        let confirmation = "Are you sure you want to discard your changes?"
        overview.verifyExistence(text: confirmation, timeout: 2.0)
        overview.tap(button: "Discard Changes")

        overview.verifyExistence(text: "Male") // make sure value didn't change
    }

    func testRemoval() {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")
        sleep(1)

        // remove image on the list
        let removeButtons = overview.images.matching(identifier: "remove")
        removeButtons.firstMatch.tap()
        overview.buttons["Delete"].tap()

        XCTAssertTrue(overview.buttons["Add Gender Identity"].waitForExistence(timeout: 2.0))

        overview.tap(button: "Done")
        sleep(3)

        XCTAssertFalse(overview.staticTexts["Male"].waitForExistence(timeout: 2.0)) // ensure value is gone
    }

    func testNameOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Name, E-Mail Address")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 6.0))

        overview.verifyExistence(text: "lelandstanford@stanford.edu")
        overview.verifyExistence(text: "Leland Stanford")

        // open user id
        overview.tap(button: "E-Mail Address, lelandstanford@stanford.edu")
        sleep(2)

        XCTAssertFalse(overview.buttons["Done"].isEnabled)

        // edit email
        try overview.textFields["E-Mail Address"].delete(count: 12, dismissKeyboard: false)

        // failed validation
        XCTAssertTrue(overview.staticTexts["The provided email is invalid."].waitForExistence(timeout: 2.0))
        XCTAssertFalse(overview.buttons["Done"].isEnabled)

        overview.app.typeText("tum.de") // we still have keyboard focus
        overview.app.dismissKeyboard()
        overview.tap(button: "Done")
        sleep(3)

        overview.verifyExistence(text: "lelandstanford@tum.de")

        // open name
        overview.tap(button: "Name, Leland Stanford")
        sleep(2)
        XCTAssertFalse(overview.buttons["Done"].isEnabled)

        // edit name
        try overview.delete(field: "enter last name", count: 8)
        overview.tap(button: "Done")
        sleep(3)

        overview.verifyExistence(text: "Leland")

        overview.navigationBars.buttons["Account Overview"].tap()
        sleep(2)
        XCTAssertTrue(overview.staticTexts["L"].waitForExistence(timeout: 2.0)) // ensure the "account image" is updated accordingly
    }

    func testAddName() throws {
        let app = TestApp.launch(defaultCredentials: true, noName: true)
        let overview = app.openAccountOverview()

        overview.verifyExistence(text: "Name, E-Mail Address")

        overview.tap(button: "Name, E-Mail Address")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 6.0))

        // open user id
        overview.tap(button: "Add Name")
        sleep(2)
        XCTAssertFalse(overview.buttons["Done"].isEnabled)

        try overview.enter(field: "enter first name", text: "Leland")
        try overview.enter(field: "enter last name", text: "Stanford")

        overview.tap(button: "Done")
        sleep(3)

        overview.verifyExistence(text: "Name, Leland Stanford")
    }

    func testSecurityOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Sign-In & Security")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Sign-In & Security"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(overview.buttons["Change Password"].waitForExistence(timeout: 2.0))
        overview.tap(button: "Change Password")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Change Password"].waitForExistence(timeout: 6.0))

        let warningLength = "Your password must be at least 8 characters long."
        overview.verifyExistence(text: warningLength) // the gray hint below

        try overview.secureTextFields["enter password"].enter(value: "12345", dismissKeyboard: false)
        sleep(1)
        XCTAssertEqual(overview.staticTexts.matching(identifier: warningLength).count, 2)
        overview.app.typeText("6789")

        overview.app.dismissKeyboard()
        sleep(1)

        try overview.secureTextFields["re-enter password"].enter(value: "12345", dismissKeyboard: false)
        overview.verifyExistence(text: "Passwords do not match.", timeout: 2.0)
        overview.app.typeText("6789")

        overview.tap(button: "Done")
        sleep(2)

        XCTAssertFalse(overview.secureTextFields["enter password"].waitForExistence(timeout: 2.0))
    }
    
    func testLicenseOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "License Information")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Package Dependencies"].waitForExistence(timeout: 6.0))
    }
}
