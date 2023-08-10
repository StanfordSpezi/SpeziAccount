# Adding new Account Values

Add new user account details by defining your own ``AccountValueKey``.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

By defining a custom ``AccountValueKey`` you can add new data points stored in your user accounts.
As an ``AccountValueKey`` define the UI components how users provide data using the ``DataEntryView`` protocol,
``AccountService``s typically do not need to be modified.

### Defining the AccountValue Key

The first step to create a new account value is to create a new type adopting the ``AccountValueKey`` protocol.

> Note: In order to implement an account value which a user is required to supply on signup, adopt the ``RequiredAccountValueKey``
    protocol instead.

When adopting the protocol, you have to provide the [Value](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/knowledgesource/value)
associated type and a ``AccountValueKey/category``.
The `Value` defines the type of the value while the `category` is used to group the account values in UI components (see ``AccountValueCategory`` for more information.)

> Note: The associated type for the value is coming from the underlying 
    [KnowledgeSource](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/knowledgesource) protocol from the Spezi framework. 
    Refer to the [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
    documentation for more information.

Below is a short code example of a short string-based biography a user might show on their profile.
```swift
public struct BiographyKey: AccountValueKey {
    public typealias Value = String
    public static let signupCategory: SignupCategory = .other
}
```

> Important: The `Value` type must be a `Sendable` type.

### Accessors

In order for our new ``AccountValueKey`` implementation to work seamlessly with the `SpeziAccount` infrastructure,
we have to declare several extensions, so we can easily access the ``AccountValueKey`` meta-type or the value stored for a given user. 

First, an extension to the ``AccountValueKeys`` type, to use the shorthand notation to refer to the ``AccountValueKey`` type.

```swift 
extension AccountValueKeys {
    public var biography: BiographyKey.Type {
        BiographyKey.self
    }
}
```

Secondly, an extension to the ``AccountValueStorageContainer`` protocol, to easily retrieve the account value from types like the
``AccountDetails`` or ``SignupDetails``.

```swift
extension AccountValueStorageContainer {
    public var biography: String {
        storage[BiographyKey.self]
    }
}
```

### Data Entry View

Each ``AccountValueKey`` has to provide a SwiftUI view that is used during signup or when the user wants to edit their current account information.

A ``AccountValueKey`` provides the mechanism through the ``DataEntryView`` protocol.
This protocol has two requirements: ``DataEntryView/Key`` defines the associated ``AccountValueKey`` type (what we just implemented) 
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
    }
}
```

> Note: If your `Value` type can be default initialized (either being a supported native type or by conforming to the `DefaultInitializable`
    protocol of the `Spezi` framework), then the ``AccountValueKey/dataEntryView-cjr6`` property is automatically implemented.
    Otherwise, you may add conformance to `DefaultInitializable` to your `Value` type or implement it as a computed property,
    returning a ``GeneralizedDataEntryView`` with an empty value.

## Topics

### Implementing Account Values

- ``AccountValueKey``
- ``RequiredAccountValueKey``
- ``AccountValueKeys``
- ``AccountValueCategory``

### Data Entry View

- ``DataEntryView``
- ``GeneralizedDataEntryView``
- ``DataEntryConfiguration``
- ``DataEntryValidationClosures``
- ``DataValidationResult``

### Account Value Storage

- ``AccountAnchor``
- ``AccountValueStorage``
- ``AccountValueStorageContainer``
- ``AccountValueStorageBuilder``
- ``AccountValueKind``
