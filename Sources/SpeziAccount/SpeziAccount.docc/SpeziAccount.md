# ``SpeziAccount``

A Spezi framework that provides account-related functionality including login, sign up and password reset.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

The `SpeziAccount` framework fully abstracts setup and management of user account functionality for the
[Spezi](https://github.com/StanfordSpezi/Spezi/) framework ecosystem.

@Row {
    @Column {
        @Image(source: "AccountSetup", alt: "Screenshot displaying the account setup view with an email and password prompt and a Sign In with Apple button.") {
            The ``AccountSetup`` is the central view for account onboarding, facilitating account login and creation.
        }
    }
    @Column {
        @Image(source: "SignupForm", alt: "Screenshot displaying the Signup Form for Account setup.") {
            The ``SignupForm`` is used by email-password-based AccountServices by default.
        }
    }
    @Column {
        @Image(source: "AccountOverview", alt: "Screenshot displaying the Account Overview.") {
            The ``AccountOverview`` is used to view and modify the user details of the currently associated account. 
        }
    }
}

The ``AccountSetup`` and ``AccountOverview`` views are central to `SpeziAccount`.
You use the ``AccountDetails`` collection within your views to visualize account information of the associated user account.

An ``AccountService`` provides an abstraction layer for managing different types of account management services
(e.g., email address and password-based service combined with an identity provider like Sign in with Apple).

> Note: The [SpeziFirebase](https://github.com/StanfordSpezi/SpeziFirebase)
framework provides the [`FirebaseAccountService`](https://swiftpackageindex.com/stanfordspezi/spezifirebase/documentation/spezifirebaseaccount/firebaseaccountservice)
you can use to configure an Account Service base on the Google Firebase service.

## Setup

You need to add the Spezi Account Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.

The <doc:Initial-Setup> article provides a quick-start guide to set up `SpeziAccount` in your App.

Refer to the <doc:Creating-your-own-Account-Service> article if you plan on implementing your own Account Service.


## Topics

### Configuration

- <doc:Initial-Setup>
- ``AccountConfiguration``
- ``AccountValueConfiguration``

### Account Details

- ``Account``
- ``AccountDetails``
- <doc:Adding-new-Account-Values>

### Account UI

- ``AccountSetup``
- ``AccountOverview``
- ``AccountHeader``
- ``FollowUpInfoSheet``
- ``SwiftUI/View/accountRequired(_:isValid:setupSheet:)``
- ``SwiftUI/EnvironmentValues/accountRequired``

### Environment & Preferences

- ``SwiftUI/View/preferredAccountSetupStyle(_:)``
- ``SwiftUI/View/followUpBehaviorAfterSetup(_:)``

### Reacting to Events

- ``AccountNotifyConstraint``
- ``AccountNotifications``

### Account Service

- <doc:Creating-your-own-Account-Service>
- ``AccountService``
- ``IdentityProvider``
- ``SecurityRelatedModifier``
- ``AccountModifications``

### External Storage

- <doc:Custom-Storage-Provider>
- ``AccountStorageProvider``
- ``ExternalAccountStorage``
- ``AccountDetailsCache``

### In Memory Implementations

In memory implementations are useful for SwiftUI Previews and UI testing purposes.
- ``InMemoryAccountService``
- ``InMemoryAccountStorageProvider``
