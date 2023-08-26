//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

enum Defaults {
    static let username = "lelandstanford"
    static let email = "lelandstanford@stanford.edu"
    static let password = "StanfordRocks123!"

    static let firstname = "Leland"
    static let lastname = "Stanford"
    static let name = "\(firstname) \(lastname)"
}

final class AccountLoginTests: XCTestCase {
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

        setup.tapLogin()

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))
    }

    func testAccountSummary() throws {
        let app = TestApp.launch(serviceType: "mail")
        var setup = app.openAccountSetup()

        // Optimize away this step
        try setup.login(email: Defaults.email, password: Defaults.password)

        // verify we are back at the start screen
        XCTAssertTrue(app.staticTexts[Defaults.email].waitForExistence(timeout: 2.0))

        setup = app.openAccountSetup()

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

        try setup.login(username: Defaults.username, password: Defaults.password)

        XCTAssertTrue(app.staticTexts[Defaults.username].waitForExistence(timeout: 2.0))
    }
}

    
extension XCUIApplication {
    fileprivate func delete(username: (field: String, count: Int), password: (field: String, count: Int)) throws {
        try textFields[username.field].delete(count: username.count)
        try secureTextFields[password.field].delete(count: password.count)
    }
    
    fileprivate func enterCredentials(username: (field: String, value: String), password: (field: String, value: String)) throws {
        let buttonTitle = "Login"
        
        testPrimaryButton(enabled: false, title: buttonTitle)
        
        try textFields[username.field].enter(value: username.value)
        testPrimaryButton(enabled: false, title: buttonTitle)
        
        try secureTextFields[password.field].enter(value: password.value)
        testPrimaryButton(enabled: true, title: buttonTitle)
    }
}
