# Using the Account Object

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Use the global `Account` object to access the current account state.

## Overview

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

## Topics

### Account and Account Details

- ``Account``
- ``Account/signedIn``
- ``Account/details``
- ``AccountDetails``

### Account Details

Below is a list of built-in account details. Other frameworks might extend this list.

- ``AccountDetails/userId``
- ``AccountDetails/email``
- ``AccountDetails/name``
- ``AccountDetails/dateOfBrith``
- ``AccountDetails/genderIdentity``

### Accessing the Account Service
To access the currently active `AccountService` or its configuration you may want to use the following properties:

- ``AccountDetails/accountService``
- ``AccountService/configuration``
- ``AccountDetails/userIdType``
