# Accessing the User Account Details

Use `Account` to access the current user account state.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->


## Overview

You can access the current user account state using the ``Account`` `Module`.
It provides information if the user is currently ``Account/signedIn`` and allows to access the user ``Account/details``.

Below is a short code example demonstrating how to access `Account` from your SwiftUI view hierarchy.
```swift
struct MyView: View {
    @Environment(Account.self) var account

    var body: some View {
        // ... use account
    }
}
```


Accessing the `Account` from within your `Module` is equally simple using the Spezi dependency system.

```swift
final class MyModule: Module {
    @Dependency(Account.self) private var account
}
```

- Note: The code example declares a required dependency and would crash if the user doesn't configure `SpeziAccount`.
    You might want to consider it as an optional dependency to gracefully handle the case where `SpeziAccount` might not be configured.

## Topics

### Account Details

- ``Account``
- ``Account/signedIn``
- ``Account/details``
- ``AccountDetails``

### Account Details

Below is a list of built-in account details. Other frameworks might extend this list.

- ``AccountDetails/accountId``
- ``AccountDetails/userId``
- ``AccountDetails/email``
- ``AccountDetails/name``
- ``AccountDetails/dateOfBrith``
- ``AccountDetails/genderIdentity``


### Accessing the Account Service
To access the currently active `AccountService` or its configuration you may want to use the following properties:

- ``AccountDetails/accountServiceConfiguration``
- ``AccountDetails/userIdType``
