//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest

@dynamicMemberLookup
protocol TestableView {
    var app: XCUIApplication { get }

    subscript<Value>(dynamicMember dynamicMember: KeyPath<XCUIApplication, Value>) -> Value { get }

    func tap(button: String)

    func enter<Input: StringProtocol>(field: String, text: Input) throws

    func enter<Input: StringProtocol>(secureField: String, text: Input) throws

    func delete(field: String, count: Int) throws

    func delete(secureField: String, count: Int) throws
}

extension TestableView {
    subscript<Value>(dynamicMember dynamicMember: KeyPath<XCUIApplication, Value>) -> Value {
        app[keyPath: dynamicMember]
    }

    func tap(button: String) {
        XCTAssertTrue(app.buttons[button].waitForExistence(timeout: 1.0))
        app.buttons[button].tap()
    }

    func enter<Input: StringProtocol>(field: String, text: Input) throws {
        try app.textFields[field].enter(value: String(text))
    }

    func enter<Input: StringProtocol>(secureField: String, text: Input) throws {
        try app.secureTextFields[secureField].enter(value: String(text))
    }

    func delete(field: String, count: Int) throws {
        try app.textFields[field].delete(count: count)
    }

    func delete(secureField: String, count: Int) throws {
        try app.secureTextFields[secureField].delete(count: count)
    }
}

struct TestableAccountSetup: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify(headerText: String = "Your Account") {
        XCTAssertTrue(app.staticTexts[headerText].waitForExistence(timeout: 2.0))
    }

    func tapLogin() {
        tap(button: "Login")
    }

    func enter<Input: StringProtocol>(email: Input) throws {
        try enter(field: "E-Mail Address", text: email)
    }

    func enter<Input: StringProtocol>(username: Input) throws {
        try enter(field: "Username", text: username)
    }

    func enter<Input: StringProtocol>(password: Input) throws {
        try enter(secureField: "Password", text: password)
    }

    func deleteEmail(count: Int) throws {
        try delete(field: "E-Mail Address", count: count)
    }

    func deletePassword(count: Int) throws {
        try delete(secureField: "Password", count: count)
    }

    func login<Email: StringProtocol, Password: StringProtocol>(email: Email, password: Password) throws {
        try enter(email: email)
        try enter(password: password)

        tapLogin()
    }

    func login<Username: StringProtocol, Password: StringProtocol>(username: Username, password: Password) throws {
        try enter(username: username)
        try enter(password: password)

        tapLogin()
    }
}

struct TestableAccountOverview: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify(headerText: String = "Account Overview") {
        XCTAssertTrue(app.staticTexts[headerText].waitForExistence(timeout: 6.0))
    }
}


struct TestApp: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    static func launch(serviceType: String = "mail") -> TestApp {
        let app = XCUIApplication()
        app.launchArguments = ["--service-type", serviceType]
        app.launch()

        let testApp = TestApp(app: app)
        testApp.verify()
        return testApp
    }

    func verify(timeout: TimeInterval = 1.0) {
        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: timeout))
    }

    func openAccountSetup() -> TestableAccountSetup {
        tap(button: "Account Setup")

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }

    func openAccountOverview() -> TestableAccountOverview {
        tap(button: "Account Overview")

        let overview = TestableAccountOverview(app: app)
        overview.verify()
        return overview
    }
}
