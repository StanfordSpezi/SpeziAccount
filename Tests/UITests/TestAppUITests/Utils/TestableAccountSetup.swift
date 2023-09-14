//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


struct TestableAccountSetup: AccountValueView {
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
        try enter(field: "E-Mail Address", text: email)
        try enter(secureField: "Password", text: password)

        tapLogin(sleep: sleepMillis)
    }

    func login<Username: StringProtocol, Password: StringProtocol>(username: Username, password: Password, sleep sleepMillis: UInt32 = 0) throws {
        try enter(field: "Username", text: username)
        try enter(secureField: "Password", text: password)

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
