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

        try disablePasswordAutofill()
    }

    func testRequirementLevelsOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.verifyExistence(text: "Leland Stanford")
        overview.verifyExistence(text: "lelandstanford@stanford.edu")

        overview.verifyExistence(text: "Name, E-Mail Address")
        overview.verifyExistence(text: "Password & Security")

        overview.verifyExistence(text: "Gender Identity")
        overview.verifyExistence(text: "Male")

        overview.verifyExistence(text: "Date of Birth")
        overview.verifyExistence(text: "Mar 9, 1824")

        XCTAssertTrue(overview.buttons["Logout"].waitForExistence(timeout: 0.5))
    }

    func testEditView() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Edit")

        XCTAssertTrue(overview.buttons["Delete Account"].waitForExistence(timeout: 0.5))

        print(overview.buttons.debugDescription)

        overview.updateGenderIdentity(from: "Male", to: "Choose not to answer")
        overview.changeDatePreviousMonthFirstDay()

        overview.tap(button: "Add Biography")
        try overview.enter(field: "Biography", text: "Hello Stanford")

        overview.dismissKeyboardExtended()
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

        // edit email
        try overview.deleteEmail(count: 12)
        overview.app.typeText("tum.de")
        overview.tap(button: "Done")
        sleep(3)

        overview.verifyExistence(text: "lelandstanford@tum.de")

        // open name
        overview.tap(button: "Name, Leland Stanford")
        sleep(2)

        // edit name
        try overview.delete(field: "Enter your last name ...", count: 8)
        overview.tap(button: "Done")
        sleep(3)

        overview.verifyExistence(text: "Leland")
    }

    func testSecurityOverview() throws {
        let app = TestApp.launch(defaultCredentials: true)
        let overview = app.openAccountOverview()

        overview.tap(button: "Password & Security")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Password & Security"].waitForExistence(timeout: 6.0))

        XCTAssertTrue(overview.buttons["Change Password"].waitForExistence(timeout: 2.0))
        overview.tap(button: "Change Password")
        sleep(2)
        XCTAssertTrue(overview.navigationBars.staticTexts["Change Password"].waitForExistence(timeout: 6.0))

        let warningLength = "Your password must be at least 8 characters long."
        overview.verifyExistence(text: warningLength) // the gray hint below

        try overview.enter(secureField: "New Password", text: "12345")
        sleep(1)
        XCTAssertEqual(overview.staticTexts.matching(identifier: warningLength).count, 2)
        overview.app.typeText("6789")

        try overview.enter(secureField: "Repeat Password", text: "12345")
        overview.verifyExistence(text: "Passwords do not match.", timeout: 2.0)
        overview.app.typeText("6789")

        overview.tap(button: "Done")
        sleep(2)

        XCTAssertFalse(overview.secureTextFields["New Password"].waitForExistence(timeout: 2.0))
    }
}
