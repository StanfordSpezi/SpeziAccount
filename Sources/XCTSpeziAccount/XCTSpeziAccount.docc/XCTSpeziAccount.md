# ``XCTSpeziAccount``

Making writing UI Tests for SpeziAccount-related functionality easier.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Topics

### Login

- ``XCTest/XCUIApplication/login(email:password:)``
- ``XCTest/XCUIApplication/login(username:password:)``

### Signup Form

- ``XCTest/XCUIApplication/fillSignupForm(email:password:name:genderIdentity:supplyDateOfBirth:)``
- ``XCTest/XCUIApplication/updateGenderIdentity(from:to:file:line:)``
- ``XCTest/XCUIApplication/changeDateOfBirth()``
- ``XCTest/XCUIApplication/closeSignupForm(discardChangesIfAsked:)``
