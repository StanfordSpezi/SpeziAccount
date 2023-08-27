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

    func tap(button: String, timeout: TimeInterval)

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
        tap(button: button, timeout: 1.0)
    }

    func tap(button: String, timeout: TimeInterval) {
        XCTAssertTrue(app.buttons[button].waitForExistence(timeout: timeout))
        app.buttons[button].tap()
    }

    func enter<Input: StringProtocol>(field: String, text: Input) throws {
        XCTAssertTrue(app.textFields[field].waitForExistence(timeout: 1.0))
        try app.textFields[field].enter(value: String(text))
    }

    func enter<Input: StringProtocol>(secureField: String, text: Input) throws {
        XCTAssertTrue(app.secureTextFields[secureField].waitForExistence(timeout: 1.0))
        try app.secureTextFields[secureField].enter(value: String(text))
    }

    func delete(field: String, count: Int) throws {
        XCTAssertTrue(app.textFields[field].waitForExistence(timeout: 1.0))
        try app.textFields[field].delete(count: count)
    }

    func delete(secureField: String, count: Int) throws {
        XCTAssertTrue(app.secureTextFields[secureField].waitForExistence(timeout: 1.0))
        try app.secureTextFields[secureField].delete(count: count)
    }

    func verifyExistence(text: String, timeout: TimeInterval = 0.5) {
        XCTAssertTrue(app.staticTexts[text].waitForExistence(timeout: timeout))
    }

    func verifyExistence(textField: String, timeout: TimeInterval = 0.5) {
        XCTAssertTrue(app.textFields[textField].waitForExistence(timeout: timeout))
    }

    func verifyExistence(secureField: String, timeout: TimeInterval = 0.5) {
        XCTAssertTrue(app.secureTextFields[secureField].waitForExistence(timeout: timeout))
    }
}


protocol CredentialsContainable: TestableView {}

extension CredentialsContainable {
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
}


struct TestableAccountSetup: CredentialsContainable {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify(headerText: String = "Your Account") {
        XCTAssertTrue(app.staticTexts[headerText].waitForExistence(timeout: 2.0))
    }

    func tapLogin(sleep sleepMillis: UInt32 = 0) {
        tap(button: "Login")
        if sleepMillis > 0 {
            sleep(sleepMillis)
        }
    }

    func login<Email: StringProtocol, Password: StringProtocol>(email: Email, password: Password, sleep sleepMillis: UInt32 = 0) throws {
        try enter(email: email)
        try enter(password: password)

        tapLogin(sleep: sleepMillis)
    }

    func login<Username: StringProtocol, Password: StringProtocol>(username: Username, password: Password, sleep sleepMillis: UInt32 = 0) throws {
        try enter(username: username)
        try enter(password: password)

        tapLogin(sleep: sleepMillis)
    }

    func openSignup(sleep sleepMillis: UInt32 = 0) -> SignupView {
        tap(button: "Signup")
        let view = SignupView(app: app)
        view.verify()
        if sleepMillis > 0 {
            sleep(sleepMillis)
        }
        return view
    }
}

struct SignupView: CredentialsContainable {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify() {
        XCTAssertTrue(app.staticTexts["Please fill out the details below to create a new account."].waitForExistence(timeout: 6.0))
    }

    func fillForm(
        email: String,
        password: String,
        name: PersonNameComponents? = nil,
        genderIdentity: String? = nil,
        supplyDateOfBirth: Bool = false
    ) throws {
        try enter(email: email)

        try enter(password: password)

        if let name {
            if let firstname = name.givenName {
                try enter(field: "Enter your first name ...", text: firstname)
            }
            if let lastname = name.familyName {
                try enter(field: "Enter your last name ...", text: lastname)
            }
        }


        // workaround some issues with closing the keyboard
        sleep(1)
        let button = app.keyboards.firstMatch.buttons.matching(identifier: "Done").firstMatch
        if button.exists {
            button.tap()
        }
        sleep(1)

        if let genderIdentity {
            app.staticTexts["Choose not to answer"].tap()
            app.buttons[genderIdentity].tap()
        }

        if supplyDateOfBirth {
            // add date button is presented if date is not required or doesn't exists yet
            if app.buttons["Add Date"].exists {
                app.buttons["Add Date"].tap()
            }
            app.datePickers.firstMatch.tap()

            // navigate to previous month and select the first date
            app.datePickers.buttons["Previous Month"].tap()
            app.datePickers.collectionViews.buttons.element(boundBy: 0).tap()

            // close the date picker again
            app.staticTexts["Date of Birth"].tap()
        }
    }

    func signup(sleep sleepMillis: UInt32 = 0) {
        tap(button: "Signup")
        if sleepMillis > 0 {
            sleep(sleepMillis)
        }
    }

    func tapBack(timeout: TimeInterval = 1.0) -> TestableAccountSetup {
        XCTAssertTrue(app.navigationBars.buttons["Back"].waitForExistence(timeout: timeout))
        app.navigationBars.buttons["Back"].tap()

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }
}

struct TestableAccountOverview: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    func verify(headerText: String = "Account Overview") {
        XCTAssertTrue(app.staticTexts[headerText].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 6.0))
    }
}


struct TestApp: TestableView {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    static func launch(
        serviceType: String = "mail",
        config: String = "default",
        defaultCredentials: Bool = false,
        flags: String...
    ) -> TestApp {
        let app = XCUIApplication()
        app.launchArguments = ["--service-type", serviceType, "--configuration-type", config]
            + (defaultCredentials ? ["--default-credentials"] : [])
            + flags
        app.launch()

        let testApp = TestApp(app: app)
        testApp.verify()
        return testApp
    }

    func verify(timeout: TimeInterval = 1.0) {
        XCTAssertTrue(app.staticTexts["Spezi Account"].waitForExistence(timeout: timeout))
    }

    func openAccountSetup(timeout: TimeInterval = 1.0) -> TestableAccountSetup {
        tap(button: "Account Setup", timeout: timeout)

        let setup = TestableAccountSetup(app: app)
        setup.verify()
        return setup
    }

    func openAccountOverview(timeout: TimeInterval = 1.0) -> TestableAccountOverview {
        tap(button: "Account Overview", timeout: timeout)

        let overview = TestableAccountOverview(app: app)
        overview.verify()
        return overview
    }
}
