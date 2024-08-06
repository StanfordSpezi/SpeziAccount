# Implementing an Account Service

Create a new Account Service implementation to integrate a user account platform.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

An `AccountService` is the abstraction layer to create and manage user accounts and can be used to integrate with existing 
user account platforms.

This article guides you through the essential steps to implement your own Account Service.

All account services have to conform to the ``AccountService`` protocol.
An `AccountService` implements account operations and notifies the ``Account`` module of any changes of the associated
``AccountDetails``.

> Tip: Use the ``Account/supplyUserDetails(_:)`` and ``Account/removeUserDetails()`` to update the associated `AccountDetails`.

The code example below demonstrates the minimal protocol requirements of an `AccountService`.
It is an empty `AccountService` that currently doesn't support setting up accounts.

> Warning: An `AccountService` must emit the ``AccountNotifications/Event/deletingAccount(_:)`` notification to allow
    other components to perform cleanup of associated account data.

```swift
import Spezi
import SpeziAccount


public actor MyAccountService: AccountService {
    public let configuration = AccountServiceConfiguration(supportedKeys: .arbitrary)

    @Dependency(Account.self)
    private var account
    @Dependency(AccountNotifications.self)
    private var notifications

    public init() {}

    public func logout() async throws {
        // remove local account association
        await account.removeUserDetails()
    }

    public func delete() async throws {
        guard let details = account.details else {
            return
        }
        // delete account details ...

        // emitting the event is mandatory
        try await notifications.reportEvent(.deletingAccount(details.accountId))

        await account.removeUserDetails()
    }

    public func updateAccountDetails(_ modifications: AccountModifications) async throws {
        // update account details

        // call account.supplyUserDetails(_:) with updated account details
    }
}
```

> Tip: Have a look at the ``InMemoryAccountService`` for an extensive `AccountService` example.

### Configuration

Every account service has to provide their ``AccountService/configuration``.
It is required to supply the ``SupportedAccountKeys``.
Other configurations can be provided through the optional result builder closure.

The code example below demonstrates how to configure an `AccountService` that supports ``SupportedAccountKeys/arbitrary`` storage of
account keys and additionally defines an ``UserIdConfiguration`` and ``RequiredAccountKeys`` configuration.

```swift
AccountServiceConfiguration(supportedKeys: .arbitrary) {
    UserIdConfiguration.emailAddress // userId key has an "email" label and uses the email keyboard

    RequiredAccountKeys {
        \.userId
        \.password
    }
}
```

> Important: If your `AccountService` only supports to store a limited set of `AccountKey`s alongside the user account information
    use ``SupportedAccountKeys/exactly(_:)`` to communicate the supported set of `AccountKey`s.
    Further, refer to the <doc:Custom-Storage-Provider> article on how to integrate with an ``AccountStorageProvider``.

### Specifying Identity Provider

An `IdentityProvider` is an entry point to setting up an account with your `AccountService`.
Your `AccountService` might support one or more identity provider.
For example, a user might sign up with a userId and a password or use a Single-Sign-On provider like
[Sign in with Apple](https://developer.apple.com/sign-in-with-apple).

Use the ``IdentityProvider`` property wrapper inside your `AccountService` to provide UI components that are used
inside the ``AccountSetup`` view that guide a user through setting up an account with your `AccountService`.

> Tip: SpeziAccount provides some UI components out of the box that can be customized to your needs.
    ``AccountSetupProviderView`` and ``SignInWithAppleButton`` are two examples.

The example below demonstrates a setup with two `IdentityProvider` declarations.
For each of them, you create a view component which interact with your `AccountService`.
You can use the SwiftUI [`Environment`](https://developer.apple.com/documentation/swiftui/environment) to access your
`AccountService` within your view.

You can specify a ``AccountSetupSection`` and an `enabled` flag with your `IdentityProvider` declaration.
You can dynamically change the configuration using the ``IdentityProvider/projectedValue`` of the `IdentityProvider`.


```swift
import AuthenticationServices
import Spezi
import SpeziAccount


private struct MySetupView: View {
    @Environment(MyAccountService.self)
    private var service

    var body: some View {
        // An AccountSetupProviderView that doesn't support password reset functionality.
        AccountSetupProviderView { credentials in
            try await service.login(userId: credentials.userId, password: credentials.password)
        } signup: { details in
            // try await service.signup(details)
        }
    }

    nonisolated init() {}
}

private struct SignInWithAppleView: View {
    @Environment(MyAccountService.self)
    private var service

    var body: some View {
        SignInWithAppleButton { request in
            service.handleRequest(request)
        } onCompletion: { result in
            service.handleCompletion(result)
        }
    }

    nonisolated init() {}
}


public actor MyAccountService: AccountService {
    public let configuration = AccountServiceConfiguration(supportedKeys: .arbitrary)

    @Dependency(Account.self)
    private var account

    @IdentityProvider(section: .primary)
    private var primarySetup = MySetupView()
    @IdentityProvider(enabled: false, section: .singleSignOn)
    private var signInWithApple = SignInWithAppleView()


    public init(supportsApple: Bool = false) {
        if supportsApple {
            $signInWithApple.isEnabled = true
        }
    }

    public func login(userId: String, password: String) async throws {
        // handle login with the provided credentials
    }

    public func signup(_ details: AccountDetails) async throws {
        // handle signup with provided details
    }

    @MainActor
    fileprivate func handleRequest(_ request: ASAuthorizationAppleIDRequest) {
        // set requested scopes and generate a nonce
    }

    @MainActor
    fileprivate func handleCompletion(_ result: Result<ASAuthorization, any Error>) {
        // handle result
    }
}
```


### Security Related Operations

Some account operations like account deletion or modifying `AccountKeys` like ``AccountDetails/userId`` or ``AccountDetails/password`` are
considered security sensitive operations and might require a authentication before the operation can complete.

Use the ``SecurityRelatedModifier`` property wrapper to inject a [`ViewModifier`](https://developer.apple.com/documentation/swiftui/viewmodifier)
that is injected into all views that might contain security related operations.

```swift
actor MyAccountService: AccountService {
    @SecurityRelatedModifier var myModifier = MyModifier()

    func delete() async throws {
        // pop up an alert that requires entering the password
        try await myModifier.ensureAuthenticated()

        // perform delete
    }
}
```

- Note: For more information refer to the documentation of ``SecurityRelatedModifier``.

## Topics

### Configuration

- ``AccountServiceConfiguration``
- ``SupportedAccountKeys``
- ``RequiredAccountKeys``
- ``UserIdConfiguration``
- ``UserIdType``
- ``FieldValidationRules``

### Managing Account Details

- ``Account/supplyUserDetails(_:)``
- ``Account/removeUserDetails()``

### Identity Provider Views

- ``AccountSetupProviderView``
- ``AccountServiceButton``
- ``SignInWithAppleButton``

### View Components

- ``SignupForm``
- ``SignupFormHeader``
- ``PasswordResetView``
- ``SuccessfulPasswordResetView``

### Credentials

- ``UserIdPasswordCredential``
