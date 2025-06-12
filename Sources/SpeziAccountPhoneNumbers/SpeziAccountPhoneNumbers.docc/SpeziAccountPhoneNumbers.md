# ``SpeziAccountPhoneNumbers``

A Spezi framework that provides phone number management functionality for user accounts that can be used with `SpeziAccount`.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

`SpeziAccountPhoneNumbers` provides phone number management functionality for the
[Spezi](https://github.com/StanfordSpezi/Spezi/) framework ecosystem, enabling users to add, verify, and manage phone numbers in their accounts.

The framework integrates with the `SpeziAccount` framework to provide a seamless phone number management experience.
It uses the [PhoneNumberKit](https://github.com/marmelroy/PhoneNumberKit) library for robust phone number validation and formatting.

## Setup

To add phone number management to your app, you need to:

1. Add the phone numbers key to your account configuration:
```swift
var configuredValues: AccountValueConfiguration {
    [
        // ... other keys ...
        .supports(\.phoneNumbers)
    ]
}
```

2. Add the `PhoneVerificationProvider` to your app's configuration:
```swift
override var configuration: Configuration {
    Configuration(standard: YourStandard()) {
        AccountConfiguration(
            // ... other configuration ...
        )
        PhoneVerificationProvider()
    }
}
```

3. Make your `Standard` conform to `PhoneVerificationConstraint` to handle phone number verification:
```swift
actor YourStandard: PhoneVerificationConstraint {
    func startVerification(_ accountId: String, _ data: StartVerificationRequest) async throws {
        // Implement phone number verification start
    }
    
    func completeVerification(_ accountId: String, _ data: CompleteVerificationRequest) async throws {
        // Implement phone number verification completion
    }
    
    func delete(_ accountId: String, _ number: PhoneNumber) async throws {
        // Implement phone number deletion
    }
}
```

## Topics

### Storage

- ``PhoneVerificationProvider``
- ``PhoneVerificationConstraint``

### Views

- ``PhoneNumbersDetailView``
- ``PhoneNumberSteps``
- ``PhoneNumberEntryField``
- ``CountryListSheet``

### Models

- ``PhoneNumberViewModel``
- ``StartVerificationRequest``
- ``CompleteVerificationRequest``
