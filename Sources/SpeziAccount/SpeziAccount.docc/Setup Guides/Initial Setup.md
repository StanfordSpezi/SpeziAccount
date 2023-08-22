# Initial Setup

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

A quick-start guide that shows you how to setup ``SpeziAccount`` in your App.

## Overview

This article guides you through the mandatory steps to get `SpeziAccount` up and running. We highlight the necessary
configuration while also showcase the essential `View` components.

### Account Configuration

The ``AccountConfiguration`` is the central configuration option to enable ``SpeziAccount`` for your App. Add it
to your `Configuration` closure of your `SpeziAppDelegate`. Below is a example configuration.

You must always supply a array of ``ConfiguredAccountKey``s that 1) define the ``AccountKeyRequirement`` level
and 2) the order in which they are displayed (according to their ``AccountKeyCategory``).

```swift
class YourAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        AccountConfiguration(configuration: [
            .requires(\.userId),
            .requires(\.password),
            .requires(\.name),
            .collects(\.dateOfBirth),
            .collects(\.genderIdentity)
        ])
    }
}
```

> Note: You may also use the ``ConfiguredAccountKey/supports(_:)-7wwdi`` configuration to mark a ``AccountKey`` as
    ``AccountKeyRequirement/supported``. Such account values are not collected during signup but may be added when
    editing your account information later on.

``AccountService``s are the central ``SpeziAccount`` component that is responsible for implementing user account
operations. ``AccountService``s can be manually provided via the ``AccountConfiguration/init(configuration:_:)``  initializer.
Otherwise, ``AccountService``s might be directly provided by other Spezi `Componet`s (like the `FirebaseAccountConfiguration`).

### Account Setup

Now that we configured ``SpeziAccount``, let's see how users can setup their account within your app.

Account setup is done through the ``AccountSetup`` view. It presents all configured ``AccountService``s. A user can choose one
``AccountService`` to setup their account.

You should make sure to handle the case where there is already an active account setup when showing the ``AccountSetup`` view.
You can use the ``Account/signedIn`` property to conditionally hide or render another view if there is already a signed in user account. Refer to the example below:

```swift
struct MyView: View {
    @EnvironmentObject var account: Account

    var body: some View {
        if !account.signedIn {
            AccountSetup()
        }
    }
}
```

Another scenario might be a Onboarding Flow where the user should be able to review the already signed in user account.
In this case you should provide a `Continue` button using the `ViewBuilder` closure. This is shown in the code example below.

```swift
struct MyView: View {
    var body: some View {
        AccountSetup {
           NavigationLink {
               // ... next view
           } label: {
               Text("Continue")
           }
        }
    }
}
```

> Note: You can also customize the header text using the ``AccountSetup/init(continue:header:)`` initializer.

### Account Overview

The ``AccountOverview`` view can be used to view or modify the information of the currently logged in user account.
You must make sure to display this view only if there is a signed in user account (see ``Account/signedIn``).

```swift
struct MyView: View {
    var body: some View {
        AccountOverview()
    }
}
```

### Accessing Account Information

You can use the ``Account`` object that is injected into your App's view hierachy as an environment object to access ``SpeziAccount``
state. Particularly useful are the published properties ``Account/signedIn`` and ``Account/details`` to access the current account
state.

Below is a short code example to access the global ``Account`` instance.
```swift
struct MyView: View {
    @EnvironmentObject var account: Account

    var body: some View {
        // ... use account
    }
}
```

### Custom Storage Provider

Some ``AccountService`` implementations might not be able to store arbitrary ``AccountKey``s. In that case you need to provide
a `Spezi` `Standard` that conforms to ``AccountStorageStandard`` and provide storage for additional user records.

## Topics

### Configuration

- ``AccountConfiguration``
- ``ConfiguredAccountKey``
- ``AccountValueConfiguration``

### Views

- ``AccountSetup``
- ``AccountOverview``

### Accessing Account Information

- ``Account``

### Providing Storage

- ``AccountStorageStandard``
