# Initial Setup

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

A quick-start guide that shows you how to set up `SpeziAccount` in your App.

## Overview

This article guides you through the mandatory steps to get `SpeziAccount` up and running.

### Account Configuration

Use the ``AccountConfiguration`` `Module` to configure `SpeziAccount` for you application.
The configuration requires an ``AccountService`` and a ordered list of ``AccountKey``s and their requirement level to be specified.
Once configured, you can access the ``Account`` `Module` in the SwiftUI view hierarchy using the `@Environment` property wrapper
or from other Spezi `Modules` using `@Dependency`.

An `AccountService` is the central component that is responsible for implementing user account operations and managing ``AccountDetails``.
The list of ``ConfiguredAccountKey``s defines the ``AccountKeyRequirement`` and the order in which account information is displayed
(though grouped by their ``AccountKey/category``).

```swift
class MyAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        AccountConfiguration(
            service: InMemoryAccountService(),
            configuration: [
                .requires(\.userId),
                .requires(\.password),
                .requires(\.name),
                .collects(\.dateOfBirth),
                .collects(\.genderIdentity)
            ]
        )
    }
}
```

> Note: You may also use the ``ConfiguredAccountKey/supports(_:)-7wwdi`` configuration to mark a ``AccountKey`` as
    ``AccountKeyRequirement/supported``. Such account keys are not collected during signup but may be added when
    editing your account information later on in the account overview.

> Note: A ``AccountService`` might only support storing a fixed set of account keys (see ``SupportedAccountKeys``).
    In those cases you may be required to supply a ``AccountStorageProvider`` to handle storage of additional account values.
    Refer to the <doc:Custom-Storage-Provider> article for information.

### Account Setup

Account setup is handled by the ``AccountSetup`` view. It presents all identity providers of the configured `AccountService`.
A user can interact with the respective view components to set up their account.

You can use the ``Account/signedIn`` and ``Account/details`` properties to determine if a user is signed in and access their account details.

```swift
struct MyView: View {
    @Environment(Account.self) var account

    var body: some View {
        AccountSetup()
    }
}
```

### Account Overview

The ``AccountOverview`` view can be used to view or modify the information of the currently logged-in user account.
Make sure to only display this view if there is an associated user account.

```swift
struct MyView: View {
    var body: some View {
        NavigationStack {
            AccountOverview()
        }
    }
}
```

## Topics

### Configuration

- ``ConfiguredAccountKey``
- ``AccountKeyRequirement``
- ``AccountKeyConfiguration``
- ``AccountOperationError``
