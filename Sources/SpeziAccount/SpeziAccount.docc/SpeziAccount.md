# ``SpeziAccount``

A Spezi framework that provides account-related functionality including login, sign up and password reset.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

The `SpeziAccount` framework fully abstracts setup and management of user account functionality for the
[Spezi](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi) framework ecosystem.

> Note: The <doc:Initial-Setup> article provides a quick-start guide to setup `SpeziAccount` in your App.

The ``AccountSetup`` and ``AccountOverview`` views are central to `SpeziAccount`.
You use the ``AccountDetails`` abstraction within your views to visualize account information of the associated user account.

An ``AccountService`` provides an abstraction layer for managing different types of account management services
(e.g. email address and password based service combined with a identity provider like Sign in With Apple).

> Note: The [SpeziFirebase](https://swiftpackageindex.com/StanfordSpezi/SpeziFirebase/documentation/spezifirebaseaccount)
    framework provides the `FirebaseAccountConfiguration` you can use to configure an Account Service base on the Google Firebase service.


## Topics

### Setup Guides

- <doc:Initial-Setup>
- <doc:Using-the-Account-Object>
- <doc:Custom-Storage-Provider>

### Account Values

- <doc:Adding-new-Account-Values>
- <doc:Handling-Account-Value-Storage>
- <doc:Validation>

### Account Services

- <doc:Creating-your-own-Account-Service>
- <doc:Customize-your-View-Styles>
