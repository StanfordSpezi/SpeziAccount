# Adding new Account Values

Support new user account details by defining your own ``AccountKey``.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

By defining a custom ``AccountKey`` you can add new data points stored in your user accounts.
An ``AccountKey`` implementation provides all required UI components both for data entry using a ``DataEntryView`` and data display using a
``DataDisplayView``. Consequentially, non of the `SpeziAccount` provided UI components nor existing ``AccountService`` implementations need to be modified.

This articles guides you through all the necessary steps of defining a new ``AccountKey``.

### Defining the AccountValue Key

The first step is to create a new type that adopts the ``AccountKey`` protocol.

> Note: Refer to the ``RequiredAccountKey`` protocol if you require a account value that is always required to be supplied if configured.

When adopting the protocol, you have to provide the associated [Value](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/knowledgesource/value)
type, a ``AccountKey/category`` and an ``AccountKey/emptyValue-10l6x``.
The `Value` defines the type of the account value while the `category` is used to group the account values in UI components (see ``AccountKeyCategory`` for more information).
The `emptyValue` is used as the initial value on signup and might be default implemented (see the `Value Conformances` section below).

> Note: The associated type for the value is coming from the underlying 
    [KnowledgeSource](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/knowledgesource) protocol from the Spezi framework. 
    Refer to the [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
    documentation for more information.

Below is a code example implementing a simple string-based biography that a user might show on their profile.
```swift
public struct BiographyKey: AccountKey {
    public typealias Value = String
    public static let signupCategory: SignupCategory = .other
}
```

### Value Conformances

Your `Value` type requires several protocol conformances.

* The `Value` type must conform to `Sendable` to be safely passed accross actor boundaries.
* The `Value` type must conform to `Equatable` to be easily notified about changes at data entry.
* The `Value` type must conform to `Codable` such that ``AccountService``s or a ``AccountStorageStandard`` can easily store and retrieve
    arbitrary `Value` types.

> Important: If your `Value` can be default initialized, either by using a supported standard type or by additionally conforming to the `Spezi`
    `DefaultInitializable` protcol, a default implementation for ``AccountKey/emptyValue-10l6x`` is automatically provided.
    Otherwise, you need to manually add a `emptyValue` property to your implementation.

### Accessors

In order for our new ``AccountKey`` implementation to work seamlessly with the ``SpeziAccount`` infrastructure,
we have to declare several extensions, so we can easily access the ``AccountKey`` meta-type or the value stored for a given user. 

First, an extension to the ``AccountKeys`` type is required, inorder to use a shorthand, `KePath`-based notation to refer to the ``AccountKey`` metatypes.

```swift 
extension AccountKeys {
    public var biography: BiographyKey.Type {
        BiographyKey.self
    }
}
```

Secondly, an extension to the ``AccountValues`` protocol is required to retrieve the account value from ``AccountValues`` instances like
``AccountDetails`` or ``SignupDetails``.

```swift
extension AccountValues {
    public var biography: String {
        storage[BiographyKey.self]
    }
}
```

### UI Components

Each ``AccountKey`` has to provide a SwiftUI view that is used during signup or when the user wants to view or edit their current account information.
Read through the following sections for more information how to provide UI components for your ``AccountKey`` implementation.

### Data Display View

The associated `DataDisplay` type provides the SwiftUI view that handles displaying a value of the ``AccountKey``.
In cases where the `Value` is `String`-based or conforms to the `CustomLocalizedStringResourceConvertible` protocol, a automatic implementation is provided.
Therefore, you typically do not need to provide a custom view implementation or you might consider adding `CustomLocalizedStringResourceConvertible` protocol
conformance to your `Value` type.

> Note: For more information on how to implement your custom data display view, refer to the ``DataDisplayView`` protocol.

#### Data Entry View

The associated ``AccountKey/DataEntry`` type provide the SwiftUI view that handles value entry of the ``AccountKey``. You must always provide a
``DataEntryView`` type.

This protocol has two requirements: ``DataEntryView/Key`` defines the associated ``AccountKey`` type (what we just implemented) 
and provides an ``DataEntryView/init(_:)`` to retrieve a `Binding` to the current (or empty) account value
from the parent view (refer to ``GeneralizedDataEntryView`` for more information).

Below is a short code example on how one could implement the ``DataEntryView`` for our new biography account value.
```swift
extension BiographyKey {
    public struct DataEntry: DataEntryView {
        public typealias Key = BiographyKey

        @Binding
        private var biography: Value

        public init(_ value: Binding<Value>) {
            self._biography = value
        }

        public var body: some View {
            VerifiableTextField("A short biography", text: $biography, axis: .vertical)
                .lineLimit(3...6)
        }
        
        // TODO you have to handle validation of data given the thing is required (if it's not a string)!
        
    }
}
```

> Important: You must handle validation of the entered account value. `SpeziAccount` automatically injects a ``ValidationEngine`` object
    into the environment if you use a `String` value. A ``VerifiableTextField`` automatically uses that.


## Topics

### Implementing Account Values

- ``AccountKey``
- ``RequiredAccountKey``
- ``AccountKeyCategory``
- ``AccountKeys``
- ``AccountValues``

### Data Display View

- ``DataDisplayView``
- ``StringBasedDisplayView``
- ``LocalizableStringBasedDisplayView``

### Data Entry View

- ``DataEntryView``
- ``GeneralizedDataEntryView``
