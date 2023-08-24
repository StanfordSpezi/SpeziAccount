# Creating your own Account Service

Create your own Account Service implementation to integrate a user account platform.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

An `AccountService` is the abstraction layer to create and manage user accounts and can be used to integrate with existing 
user account platforms.

This article guides you through the essential steps to implement your own Account Service.

### Deciding on the type of Account Service

`SpeziAccount` provides several different ``AccountService`` protocols (see ``EmbeddableAccountService``, ``UserIdPasswordAccountService`` and ``IdentityProvider``).
Refer to their documentation to evaluate which protocol fits your need best. Typically, if your account credentials are made up from an user identifier
and a password you would want to go for the ``UserIdPasswordAccountService`` and benefit from a lot of the UI components already provided.

### Account Service Configuration

Every account service has to provide their ``AccountServiceConfiguration`` through the ``AccountService/configuration`` property. Required information is
the ``AccountServiceName`` and ``SupportedAccountKeys`` configuration. Other configurations can be provided through the optional result builder closure.

Below is a short code example that demonstrates usage of the ``SupportedAccountKeys/arbitrary``, ``UserIdConfiguration`` and ``RequiredAccountKeys`` configuration.

```swift
AccountServiceConfiguration(name: "My Account Service", supportedKeys: .arbitrary) {
    UserIdConfiguration(type: .emailAddress, keyboardType: .emailAddress) // the default for this configuration

    RequiredAccountKeys {
        \.userId
        \.password
    }
}
```

### Implementing your Account Service

Apart from implementing the ``AccountService`` protocol, an account service is responsible for notifying the global ``Account`` context
of any changes of the user state (e.g. user information updated remotely).

Do so the you can use the ``AccountService/AccountReference`` property wrapper to get access to the ``Account`` context. You can then use
the ``Account/supplyUserDetails(_:)`` and ``Account/removeUserDetails()`` methods to update the account state. Below is a short code example
that implements a basic remote sessione expiration handler.

> Note: You will always need to call the ``Account/supplyUserDetails(_:)`` and ``Account/removeUserDetails()`` methods manually,
even if the change in user state is caused by a local operation like ``AccountService/signUp(signupDetails:)`` or ``AccountService/logout()``.

```swift
actor MyAccountService: AccountService {
    @AccountReference var account

    func handleRemoteLogout() async {
        await account.removeUserDetails()
    }
}
```

Refer to the respective ``AccountService`` protocol for a list of operations you have to implement.

> Note: Have a look at the <doc:Handling-Account-Value-Storage> article on how to handle and manipulate account values storage containers.

The UI components of your ``AccountService`` used within the ``AccountSetup`` view are defined through a ``AccountSetupViewStyle`` (see ``AccountService/viewStyle-swift.property``).
Have a look at the <doc:Customize-your-View-Styles> article for more information on this topic.

### Setting up your Account Service

There are two basic approaches to set up an account service using the ``AccountServiceConfiguration`` in your `Spezi` app.

The first approach is to provide your ``AccountService`` as is and let the user create an instance of the account service themselves to
pass it to the result builder closure of the ``AccountServiceConfiguration/init(name:supportedKeys:configuration:)`` initializer.
This is the preferred approach for account services that don't require additional setup or rely on any special infrastructure.

If your account service requires additional setup or any infrastructure that relies on other `Component`s you can implement
your own `Spezi` [Component](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/component) that _provides_ your
``AccountService`` directly to the ``AccountServiceConfiguration`` component. To do so, declare the `@Provide` property wrapper with a type of
`any AccountService` and populate it within your initializer. Below is a code example.

```swift
class MyComponent: Component {
    @Provide var accountService: any AccountService // you can also use a type of [any AccountService] to provide multiple with a single @Provide

    init() {
        accountService = MyAccountService()
    }

    func configure() {
        // set up your infrastructure and e.g. register event handlers to the `accountService`
    }
}
```

> Note: Refer to the [Component Communication](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/component#Communication) documentation
    of the `Spezi` framework for more detailed information.


## Topics

### Account Services

- ``AccountService``
- ``EmbeddableAccountService``
- ``UserIdPasswordAccountService``
- ``IdentityProvider``

### Providing Configuration

- ``AccountServiceConfiguration``
- ``AccountServiceName``
- ``AccountServiceImage``
- ``SupportedAccountKeys``
- ``RequiredAccountKeys``
- ``UserIdConfiguration``
- ``UserIdType``
- ``FieldValidationRules``

### Managing Account Details

- ``Account/supplyUserDetails(_:)``
- ``Account/removeUserDetails()``
