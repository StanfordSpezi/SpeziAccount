# Custom Storage Provider

Store arbitrary account values by providing a ``AccountStorageStandard`` implementation.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

In certain cases, a given ``AccountService`` implementation might be limited to storing only a fixed set of account values.
If you have ``ConfiguredAccountKey``s that are not part of the ``SupportedAccountKeys`` set of a configured ``AccountService``
you can provide a ``AccountStorageStandard`` conformance to your `Spezi`
[Standard](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard) to handle storage of additional
account values.

### Define the Conformance

Refer to the documentation of the ``AccountStorageStandard`` protocol for more information on the required implementation.

Contact the [Standard Conformance](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard#1-Standard-Conformance)
section of the `Spezi` documentation on how to conform to `Standard` constraints.

> Note: Have a look at the <doc:Handling-Account-Value-Storage> article on how to handle and manipulate account values storage containers.

### App Configuration

Below is a short code example on how to set up your Standard in your App's configuration section. Refer to the 
[Standard Definition](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard#2-Standard-Definition) section
of the `Spezi` documentation for more information.

```swift
var configuration: Configuration {
    Configuration(standard: ExampleStorageStandard()) {
        // ... `AccountConfiguration` and Account Service configuration
    }
}
```

> Note: Your ``AccountStorageStandard`` will be used to handle data flow for all configured ``AccountService``s that do not support a least one
    ``ConfiguredAccountKey``.

## Topics

### Providing Storage

- ``AccountStorageStandard``
- ``StandardBackedAccountService``

### Identifiyng Additional Storage Records

- ``AdditionalRecordId``
