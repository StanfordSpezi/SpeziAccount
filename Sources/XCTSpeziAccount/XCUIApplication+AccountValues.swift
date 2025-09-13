//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    /// Update the gender identity picker.
    /// - Parameters:
    ///   - from: The currently selected value.
    ///   - to: The new selected value.
    ///   - file: The file where this is executed.
    ///   - line: The line where this is executed.
    public func updateGenderIdentity(from: String, to: String, file: StaticString = #filePath, line: UInt = #line) {
        #if os(visionOS)
        buttons["Gender Identity, \(from)"].tap()
        #else
        staticTexts[from].tap()
        #endif
        XCTAssertTrue(buttons[to].waitForExistence(timeout: 0.5), "Couldn't locate gender identity dropdown", file: file, line: line)
        buttons[to].tap()
    }
    
    /// Change the date of birth.
    ///
    /// Typically it will select the first day of the previous month. This method will make sure to add a date of birth if none is added yet.
    public func changeDateOfBirth() {
        // add date button is presented if date is not required or doesn't exists yet
        if buttons["Add Date of Birth"].exists { // uses the accessibility label
            buttons["Add Date of Birth"].tap()
        }

        XCTAssertTrue(datePickers.firstMatch.waitForExistence(timeout: 2.0), "Failed to find date of birth picker")
        datePickers.firstMatch.tap()

        // navigate to previous month and select the first date
        XCTAssertTrue(datePickers.buttons["Previous Month"].waitForExistence(timeout: 2.0), "Couldn't find 'Previous Month' button")
        datePickers.buttons["Previous Month"].tap()

        XCTAssert(buttons["PopoverDismissRegion"].waitForExistence(timeout: 0.5))
        buttons["PopoverDismissRegion"].tap()
    }
}
