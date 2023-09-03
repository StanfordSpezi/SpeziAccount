//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIElement {
    func selectTextField() {
        // The regular `enter(value:) will hit our "Done" button https://github.com/StanfordBDHG/XCTestExtensions/issues/16
        let keyboard = XCUIApplication().keyboards.firstMatch
        var offset = 0.99
        repeat {
            coordinate(withNormalizedOffset: CGVector(dx: offset, dy: 0.5)).tap()
            offset -= 0.05
        } while !keyboard.waitForExistence(timeout: 2.0) && offset > 0
    }
}


extension XCUIApplication {
    func dismissKeyboardExtended() {
        sleep(1)
        dismissKeyboard()
        let button = keyboards.firstMatch.buttons.matching(identifier: "Done").firstMatch
        if button.exists {
            button.tap()
        }
        sleep(1)
    }
}
