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

    func tap(button: String)

    func tap(button: String, timeout: TimeInterval)

    func enter<Input: StringProtocol>(field: String, text: Input) throws

    func enter<Input: StringProtocol>(secureField: String, text: Input) throws

    func delete(field: String, count: Int) throws

    func delete(secureField: String, count: Int) throws

    subscript<Value>(dynamicMember dynamicMember: KeyPath<XCUIApplication, Value>) -> Value { get }
}

extension TestableView {
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

    func dismissKeyboardExtended() {
        sleep(1)
        app.dismissKeyboard()
        let button = app.keyboards.firstMatch.buttons.matching(identifier: "Done").firstMatch
        if button.exists {
            button.tap()
        }
        sleep(1)
    }


    subscript<Value>(dynamicMember dynamicMember: KeyPath<XCUIApplication, Value>) -> Value {
        app[keyPath: dynamicMember]
    }
}
