# External Storage of Account Details

External storage of account values if not supported by the `AccountService`.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

A ``AccountService`` might be limited to only support storing a specific set of ``AccountKey``s alongside the user account information.
In these situations, additional ``AccountDetails`` need to be stored via an external ``AccountStorageProvider``.
Use the ``AccountConfiguration/init(service:storageProvider:configuration:)`` initializer to set up an `AccountStorageProvider` with `SpeziAccount`.

```swift
override var configuration: Configuration {
    Configuration {
        AccountConfiguration(
            service: SomeAccountService(),
            storageProvider: SomeStorageProvider(),
            configuration: [
                // your configuration ...
            ]
        )
    }
}
```


This articles illustrates how to create an `AccountStorageProvider` and how a `AccountService` that doesn't support to store arbitrary account details
can use the ``ExternalAccountStorage`` `Module` to interact with the configured storage provider.

### Implementing an Account Storage Provider

To implement an external storage provider you have to adopt the ``AccountStorageProvider`` protocol.

> Tip: You can have a look at the ``InMemoryAccountStorageProvider`` for an example of an storage provider that
    stores all data locally.

```swift
public actor MyProvider: AccountStorageProvider {
    @Dependency(ExternalAccountStorage.self)
    private var storage

    public func create(_ accountId: String, _ details: AccountDetails) async throws {
        // handle creation of a new record
        try await modify(accountId, AccountModifications(modifiedDetails: details))
    }

    public func load(_ accountId: String, _ keys: [any AccountKey.Type]) async throws -> AccountDetails? {
        // Contact local cache if details are present.
        // If not, return `nil` and notify account service about details retrieved from remote service
        // by calling storage.notifyAboutUpdatedDetails(for:_:).
    }

    public func modify(_ accountId: String, _ modifications: AccountModifications) async throws {
        // update stored details
    }

    public func disassociate(_ accountId: String) async {
        // clear locally cached data
    }

    public func delete(_ accountId: String) async throws {
        // remove record and clear locally cached data
    }
}
```

> Tip: The ``AccountStorageProvider/load(_:_:)`` method must return instantly. You may use the ``AccountDetailsCache`` module
    to locally cache ``AccountDetails`` on disk.

### Interacting with a Storage Provider

If your `AccountService` implementation doesn't support storing arbitrary account details, you are required to interact with the
an external storage provide through the ``ExternalAccountStorage`` `Module` yourself.

> Tip: The ``InMemoryAccountService`` is a great example on how to interact with an `AccountStorageProvider`.

Make sure to implement your `AccountService` the following way
* Declare a dependency to `ExternalAccountStorage`: `@Dependency(ExternalAccountStorage.self) var storage`
* Make sure to subscribe to updates from the storage provider using the `AsyncStream` ``ExternalAccountStorage/updatedDetails``.
* Create a new record by calling ``ExternalAccountStorage/requestExternalStorage(of:for:)``.
* Update externally stored details by calling ``ExternalAccountStorage/updateExternalStorage(with:for:)``.
* Retrieve externally stored details by calling ``ExternalAccountStorage/retrieveExternalStorage(for:_:)-8gbg`` 

> Note: Refer to the documentation of ``ExternalAccountStorage`` for more information.
