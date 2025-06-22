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

1.1 (Optional) Configure custom encoding/decoding strategy for SpeziFirebase storage:

If you use `FirestoreAccountStorage` as your storage provider, you can customize how phone numbers are encoded and decoded. By default, phone numbers are stored with all their properties as key-value pairs. To store only the E.164 string format (e.g., "+16502341234"), configure custom encoder and decoder instances:

```swift
override var configuration: Configuration {
    Configuration(standard: YourStandard()) {
        AccountConfiguration(
            storageProvider: FirestoreAccountStorage(
                storeIn: Firestore.userCollection,
                mapping: [
                    "phoneNumbers": AccountKeys.phoneNumbers,
                    // ... other mappings ...
                ],
                encoder: customEncoder,
                decoder: customDecoder
            ),
            // ... other configuration ...
        )
    }
}

private var customEncoder: FirebaseFirestore.Firestore.Encoder {
    let encoder = FirebaseFirestore.Firestore.Encoder()
    encoder.userInfo[CodingUserInfoKey(rawValue: "com.roymarmelstein.PhoneNumberKit.encoding-strategy")!] = PhoneNumberDecodingStrategy.e164
    return encoder
}

private var customDecoder: FirebaseFirestore.Firestore.Decoder {
    let decoder = FirebaseFirestore.Firestore.Decoder()
    decoder.userInfo[CodingUserInfoKey(rawValue: "com.roymarmelstein.PhoneNumberKit.decoding-strategy")!] = PhoneNumberDecodingStrategy.e164
    return decoder
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
    func startVerification(_ number: PhoneNumber) async throws {
        // Implement phone number verification start
    }
    
    func completeVerification(_ number: PhoneNumber, _ code: String) async throws {
        // Implement phone number verification completion
    }
    
    func delete(_ number: PhoneNumber) async throws {
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
