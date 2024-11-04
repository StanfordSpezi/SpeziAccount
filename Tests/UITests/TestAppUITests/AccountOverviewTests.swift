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


final class AccountOverviewTests: XCTestCase { // swiftlint:disable:this type_body_length
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
    }

    @MainActor
    func testRequirementLevelsOverview() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.staticTexts["Leland Stanford"].exists)
        XCTAssertTrue(app.staticTexts["lelandstanford@stanford.edu"].exists)

        XCTAssertTrue(app.staticTexts["Name, E-Mail Address"].exists)
        XCTAssertTrue(app.staticTexts["Sign-In & Security"].exists)

        XCTAssertTrue(app.staticTexts["Gender Identity, Male"].exists)
        XCTAssertTrue(app.staticTexts["Date of Birth, Mar 9, 1824"].exists)

#if os(visionOS)
        app.scrollUpInOverview()
#endif
        XCTAssertTrue(app.staticTexts["License Information"].exists)
        XCTAssertTrue(app.buttons["Logout"].exists)
    }

    @MainActor
    func testEditView() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Edit"].exists)
        app.buttons["Edit"].tap()

        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2.0))

        app.updateGenderIdentity(from: "Male", to: "Choose not to answer")
#if !os(visionOS)
        // on visionOS we are currently unable to tap on date pickers :)
        app.changeDateOfBirth()
#endif

        XCTAssertTrue(app.buttons["Add Biography"].exists)
        app.buttons["Add Biography"].tap()

        XCTAssertTrue(app.textFields["Biography"].exists)
        try app.textFields["Biography"].enter(value: "Hello Stanford")

        XCTAssertTrue(app.navigationBars.buttons["Done"].exists)
        app.navigationBars.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Gender Identity, Choose not to answer"].waitForExistence(timeout: 4.0))
        XCTAssertTrue(app.staticTexts["Biography, Hello Stanford"].exists)
    }

    @MainActor
    func testLogout() {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

#if os(visionOS)
        app.scrollUpInOverview()
#endif

        XCTAssertTrue(app.buttons["Logout"].exists)
        app.buttons["Logout"].tap()

        let alert = "Are you sure you want to logout?"
        XCTAssertTrue(app.alerts[alert].waitForExistence(timeout: 4.0))
        app.alerts[alert].scrollViews.otherElements.buttons["Logout"].tap()

        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["lelandstanford@stanford.edu"].exists)
    }

    @MainActor
    func testAccountRemoval() {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Edit"].exists)
        app.buttons["Edit"].tap()

        #if os(visionOS)
        app.scrollUpInOverview()
        #endif

        XCTAssertTrue(app.buttons["Delete Account"].waitForExistence(timeout: 0.5))
        app.buttons["Delete Account"].tap()

        let alert = "Are you sure you want to delete your account?"
        XCTAssertTrue(app.alerts[alert].waitForExistence(timeout: 6.0))
        app.alerts[alert].scrollViews.otherElements.buttons["Delete"].tap()

        XCTAssertTrue(app.alerts["Security Alert"].waitForExistence(timeout: 6.0))
        app.alerts["Security Alert"].buttons["Continue"].tap()

        XCTAssertTrue(app.staticTexts["Got notified about deletion!"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.staticTexts["lelandstanford@stanford.edu"].exists)
    }

    @MainActor
    func testEditDiscard() {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Edit"].exists)
        app.buttons["Edit"].tap()

        // no changes, should just leave edit mode
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2.0))
        app.buttons["Cancel"].tap()


        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 2.0))
        app.buttons["Edit"].tap()
        app.updateGenderIdentity(from: "Male", to: "Choose not to answer")

        XCTAssertTrue(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()


        let confirmation = "Are you sure you want to discard your changes?"
        XCTAssertTrue(app.staticTexts[confirmation].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Keep Editing"].exists)
        app.buttons["Keep Editing"].tap()

        XCTAssertTrue(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts[confirmation].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Discard Changes"].exists)
        app.buttons["Discard Changes"].tap()

        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 2.0)) // make sure value didn't change
    }

    @MainActor
    func testRemoveDiscard() {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Edit"].exists)
        app.buttons["Edit"].tap()

        // remove image on the list
        let removeButton = app.images.matching(identifier: "remove").firstMatch
        XCTAssertTrue(removeButton.waitForExistence(timeout: 2.0))
        removeButton.tap()
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 0.5))
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.buttons["Add Gender Identity"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()

        let confirmation = "Are you sure you want to discard your changes?"
        XCTAssertTrue(app.staticTexts[confirmation].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Discard Changes"].exists)
        app.buttons["Discard Changes"].tap()

        XCTAssertTrue(app.staticTexts["Male"].waitForExistence(timeout: 2.0)) // make sure value didn't change
    }

    @MainActor
    func testRemoval() {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Edit"].exists)
        app.buttons["Edit"].tap()

        // remove image on the list
        let removeButton = app.images.matching(identifier: "remove").firstMatch
        XCTAssertTrue(removeButton.waitForExistence(timeout: 2.0))
        removeButton.tap()
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 0.5))
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.buttons["Add Gender Identity"].waitForExistence(timeout: 2.0))

        XCTAssertTrue(app.buttons["Done"].exists)
        app.buttons["Done"].tap()

        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 3.0))
        XCTAssertFalse(app.staticTexts["Male"].exists) // ensure value is gone
    }

    @MainActor
    func testNameOverview() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Name, E-Mail Address"].exists)
        app.buttons["Name, E-Mail Address"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 4.0))

        XCTAssertTrue(app.staticTexts["lelandstanford@stanford.edu"].exists)
        XCTAssertTrue(app.staticTexts["Leland Stanford"].exists)

        // open user id
        XCTAssertTrue(app.buttons["E-Mail Address, lelandstanford@stanford.edu"].exists)
        app.buttons["E-Mail Address, lelandstanford@stanford.edu"].tap()
        XCTAssertTrue(app.navigationBars.buttons["Done"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.navigationBars.buttons["Done"].isEnabled)

        // edit email
        #if !os(visionOS)
        try app.textFields["E-Mail Address"].delete(count: 12, options: [.disableKeyboardDismiss, .tapFromRight])
        #else
        // on visionOS we tap the cursor after the dot. We just split it up into two 6 character deletes
        try app.textFields["E-Mail Address"].delete(count: 6, options: [.disableKeyboardDismiss])
        try app.textFields["E-Mail Address"].delete(count: 6, options: [.disableKeyboardDismiss])
        #endif

        // failed validation
        XCTAssertTrue(app.staticTexts["The provided email is invalid."].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.buttons["Done"].isEnabled)

        try app.textFields["E-Mail Address"].enter(value: "tum.de", options: .skipTextFieldSelection)
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 2.0))
        app.buttons["Done"].tap()

        XCTAssertTrue(app.alerts["Security Alert"].waitForExistence(timeout: 6.0))
        app.alerts["Security Alert"].buttons["Continue"].tap()

        XCTAssertTrue(app.staticTexts["lelandstanford@tum.de"].waitForExistence(timeout: 2.0))

        // open name
        XCTAssertTrue(app.buttons["Name, Leland Stanford"].exists)
        app.buttons["Name, Leland Stanford"].tap()
        XCTAssertTrue(app.navigationBars.buttons["Done"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.buttons["Done"].isEnabled)

        // edit name
        XCTAssertTrue(app.textFields["enter last name"].exists)
        try app.textFields["enter last name"].delete(count: 8)
        XCTAssertTrue(app.buttons["Done"].isEnabled)
        app.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Name, Leland"].waitForExistence(timeout: 2.0))

        app.navigationBars.buttons["Account Overview"].tap()
        XCTAssertTrue(app.staticTexts["L"].waitForExistence(timeout: 2.0)) // ensure the "account image" is updated accordingly
    }

    @MainActor
    func testAddName() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn, noName: true)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Name, E-Mail Address"].exists)
        app.buttons["Name, E-Mail Address"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Name, E-Mail Address"].waitForExistence(timeout: 2.0))

        // open user id
        XCTAssertTrue(app.buttons["Add Name"].exists, "Name seems to be present which is unexpected")
        app.buttons["Add Name"].tap()
        XCTAssertTrue(app.navigationBars.buttons["Done"].waitForExistence(timeout: 2.0))
        XCTAssertFalse(app.navigationBars.buttons["Done"].isEnabled)

        XCTAssertTrue(app.textFields["enter first name"].exists)
        XCTAssertTrue(app.textFields["enter last name"].exists)
        try app.textFields["enter first name"].enter(value: "Leland")
        try app.textFields["enter last name"].enter(value: "Stanford")

        app.navigationBars.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Name, Leland Stanford"].waitForExistence(timeout: 2.0))
    }

    @MainActor
    func testSecurityOverview() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

        XCTAssertTrue(app.buttons["Sign-In & Security"].exists)
        app.buttons["Sign-In & Security"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Sign-In & Security"].waitForExistence(timeout: 4.0))

        XCTAssertTrue(app.buttons["Change Password"].waitForExistence(timeout: 2.0))
        app.buttons["Change Password"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Change Password"].waitForExistence(timeout: 4.0))

        let warningLength = "Your password must be at least 8 characters long."
        XCTAssertTrue(app.staticTexts[warningLength].waitForExistence(timeout: 2.0)) // the section footer

        XCTAssertTrue(app.secureTextFields["enter password"].exists)
        XCTAssertTrue(app.secureTextFields["re-enter password"].exists)

        try app.secureTextFields["enter password"].enter(value: "12345", options: .disableKeyboardDismiss)
        XCTAssertTrue(app.staticTexts.matching(identifier: warningLength).firstMatch.waitForExistence(timeout: 2.0))
        XCTAssertEqual(app.staticTexts.matching(identifier: warningLength).count, 2) // additional red warning.
        try app.secureTextFields["enter password"].enter(value: "6789", options: .skipTextFieldSelection)

        try app.secureTextFields["re-enter password"].enter(value: "12345", options: .disableKeyboardDismiss)
        XCTAssertTrue(app.staticTexts["Passwords do not match."].waitForExistence(timeout: 2.0))
        try app.secureTextFields["re-enter password"].enter(value: "6789", options: .skipTextFieldSelection)

        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 2.0))
        app.buttons["Done"].tap()

        XCTAssertTrue(app.alerts["Security Alert"].waitForExistence(timeout: 6.0))
        app.alerts["Security Alert"].buttons["Continue"].tap()

        XCTAssertTrue(app.navigationBars.staticTexts["Sign-In & Security"].waitForExistence(timeout: 4.0))
    }

    @MainActor
    func testLicenseOverview() throws {
        let app = XCUIApplication()
        app.launch(credentials: .createAndSignIn)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Spezi Account"].exists)

        app.openAccountOverview()

#if os(visionOS)
        app.scrollUpInOverview()
#endif

        XCTAssertTrue(app.buttons["License Information"].exists)
        app.buttons["License Information"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Package Dependencies"].waitForExistence(timeout: 3.0))
    }
}


extension XCUIApplication {
#if os(visionOS)
    fileprivate func scrollUpInOverview() {
        // swipeUp doesn't work on visionOS, so we improvise

        XCTAssertTrue(staticTexts["Personal Details"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(staticTexts["Leland Stanford"].exists)
        staticTexts["Personal Details"].press(forDuration: 0, thenDragTo: staticTexts["Leland Stanford"])
    }
#endif
}
