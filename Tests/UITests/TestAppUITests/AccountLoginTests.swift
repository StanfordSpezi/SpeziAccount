//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountLoginTests: XCTestCase {
    func testLoginUsernameComponents() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Login"].waitForExistence(timeout: 2))
        app.buttons["Login"].tap()
        
        XCTAssert(app.buttons["Username and Password"].waitForExistence(timeout: 2))
        app.buttons["Username and Password"].tap()
        
        XCTAssert(app.navigationBars.buttons["Login"].waitForExistence(timeout: 2))
        
        let usernameField = "Enter your username ..."
        let passwordField = "Enter your password ..."
        let username = "lelandstanford"
        let password = "StanfordRocks123!"
        
        try app.enterCredentials(
            username: (usernameField, username),
            password: (passwordField, String(password.dropLast(2)))
        )
        
        XCTAssertTrue(app.alerts["Credentials do not match"].waitForExistence(timeout: 10.0))
        app.alerts["Credentials do not match"].scrollViews.otherElements.buttons["OK"].tap()
        
        try app.delete(
            username: (usernameField, username.count),
            password: (passwordField, password.count)
        )
        
        try app.enterCredentials(
            username: (usernameField, username),
            password: (passwordField, password)
        )
        
        XCTAssertTrue(app.collectionViews.staticTexts[username].waitForExistence(timeout: 10.0))
    }
    
    func testLoginEmailComponents() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Login"].waitForExistence(timeout: 2))
        app.buttons["Login"].tap()
        
        XCTAssert(app.buttons["Email and Password"].waitForExistence(timeout: 2))
        app.buttons["Email and Password"].tap()
        
        XCTAssert(app.navigationBars.buttons["Login"].waitForExistence(timeout: 2))
        
        let usernameField = "Enter your email ..."
        let passwordField = "Enter your password ..."
        let username = "lelandstanford@stanford.edu"
        let password = "StanfordRocks123!"
        
        try app.textFields[usernameField].enter(value: String(username.dropLast(4)))
        try app.secureTextFields[passwordField].enter(value: password)
        
        XCTAssertTrue(app.staticTexts["The entered email is not correct."].waitForExistence(timeout: 1.0))
        XCTAssertFalse(app.scrollViews.otherElements.buttons["Login, In progress"].waitForExistence(timeout: 0.5))
        
        try app.delete(
            username: (usernameField, username.dropLast(4).count),
            password: (passwordField, password.count)
        )
        
        try app.enterCredentials(
            username: (usernameField, username),
            password: (passwordField, String(password.dropLast(2)))
        )
        
        XCTAssertTrue(XCUIApplication().alerts["Credentials do not match"].waitForExistence(timeout: 6.0))
        XCUIApplication().alerts["Credentials do not match"].scrollViews.otherElements.buttons["OK"].tap()
        
        try app.delete(
            username: (usernameField, username.count),
            password: (passwordField, password.count)
        )
        
        try app.enterCredentials(
            username: (usernameField, username),
            password: (passwordField, password)
        )
        
        XCTAssertTrue(app.collectionViews.staticTexts[username].waitForExistence(timeout: 6.0))
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
