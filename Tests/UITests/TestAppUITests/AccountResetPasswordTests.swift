//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class AccountResetPasswordTests: XCTestCase {
    func testResetPasswordUsernameComponents() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Login"].waitForExistence(timeout: 2))
        app.buttons["Login"].tap()
        
        XCTAssert(app.buttons["Username and Password"].waitForExistence(timeout: 2))
        app.buttons["Username and Password"].tap()
        
        XCTAssert(app.buttons["Forgot Password?"].waitForExistence(timeout: 2))
        app.buttons["Forgot Password?"].tap()
        
        XCTAssert(app.navigationBars.buttons["Login"].waitForExistence(timeout: 2))
        
        let usernameField = "Enter your username ..."
        let username = "lelandstanford"
        let buttonTitle = "Reset Password"
        let navigationBarButtonTitle = "Login"
        
        app.testPrimaryButton(enabled: false, title: buttonTitle, navigationBarButtonTitle: navigationBarButtonTitle)
        
        try app.textFields[usernameField].enter(value: username)
        
        app.testPrimaryButton(enabled: true, title: buttonTitle, navigationBarButtonTitle: navigationBarButtonTitle)
        
        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 6.0))
    }
    
    func testResetPasswordEmailComponents() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Login"].waitForExistence(timeout: 2))
        app.buttons["Login"].tap()
        
        XCTAssert(app.buttons["Email and Password"].waitForExistence(timeout: 2))
        app.buttons["Email and Password"].tap()
        
        XCTAssert(app.buttons["Forgot Password?"].waitForExistence(timeout: 2))
        app.buttons["Forgot Password?"].tap()
        
        XCTAssert(app.navigationBars.buttons["Login"].waitForExistence(timeout: 2))
        
        let usernameField = "Enter your email ..."
        let username = "lelandstanford@stanford.edu"
        let buttonTitle = "Reset Password"
        let navigationBarButtonTitle = "Login"
        
        app.testPrimaryButton(enabled: false, title: buttonTitle, navigationBarButtonTitle: navigationBarButtonTitle)
        
        try app.textFields[usernameField].enter(value: String(username.dropLast(4)))
        
        XCTAssertTrue(app.staticTexts["The entered email is not correct."].waitForExistence(timeout: 1.0))
        
        try app.textFields[usernameField].delete(count: username.count)
        try app.textFields[usernameField].enter(value: username)
        
        app.testPrimaryButton(enabled: true, title: buttonTitle, navigationBarButtonTitle: navigationBarButtonTitle)
        
        XCTAssertTrue(app.staticTexts["Sent out a link to reset the password."].waitForExistence(timeout: 6.0))
    }
}
