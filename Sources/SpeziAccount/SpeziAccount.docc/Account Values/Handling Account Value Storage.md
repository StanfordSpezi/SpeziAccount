# Handling Account Value Storage

How to build and modify account value storage.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

``AccountValues`` implementations are used to store values for a given ``AccountKey`` definition.

There exist several different containers types. While they are identical in the underlying storage mechanism with only very
few differences in construction operations, they convey entirely different semantics and are used within their respective context only.

### Accessing Account Information 

``AccountKey``s define an extension to the ``AccountValues`` so account values can be conveniently accessed. For example, the
``PersonNameKey`` defines the ``AccountValues/name`` property as an extension to access the name of a person if it exists.
Otherwise, you can always access the underlying [Shared Repository](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/shared-repository)
using the ``AccountValues/storage`` property.

### Iterating through Account Values

You can iterate through ``AccountValues`` in a type-safe way using the [Visitor Pattern](https://en.wikipedia.org/wiki/Visitor_pattern).
This is provided through the ``AccountValueVisitor`` protocol and the ``AcceptingAccountValueVisitor/acceptAll(_:)-9hgw5`` method all
``AccountValues`` collections implement.

Below is a short code example that demonstrates the capabilities of a ``AccountValueVisitor`` to encode all stored values of a ``AccountDetails`` instance.

```swift
import Foundation

struct Visitor: AccountValueVisitor {
    private let encoder = JSONEncoder()
    private var codableStorage: [String: Data] = [:]

    mutating func visit<Key: AccountKey>(_ key: Key.Type, _ value: Key.Value) {
        // in a real world implementation one would need to collect all thrown errors. We ignore them for the sake of the example.
        codableStorage["\(Key.self)"] = try? encoder.encode(value)
    }

    func final() -> [String: Data] { // final method provides the return type for `acceptAll`
        codableStorage
    }
}

var visitor = Visitor()
let encoded = details.acceptAll(&visitor)
```

> Important: ``AccountValues`` implement the `Collection` protocol and therefore support iteration. However, `Element`s of the collection are of type
    [AnyRepositoryValue](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/anyrepositoryvalue) as ``AccountValues`` might store
    non-``AccountKey`` conforming knowledge sources like the ``ActiveAccountServiceKey``.

### Iterating through Account Keys

You can iterate through a collection of ``AccountKey``s in a type-safe way using the [Visitor Pattern](https://en.wikipedia.org/wiki/Visitor_pattern).
This is provided through the ``AccountKeyVisitor`` protocol and the ``AcceptingAccountKeyVisitor/acceptAll(_:)-1ytax`` method all implemented by
`[any AccountKey.Type]` arrays or ``AccountKeyCollection``s. This is useful when you are accessing the ``AccountValues/keys-572sk`` property or
implement a custom storage provider (see ``AccountStorageStandard/load(_:_:)``).

An implementation is similarly structured to the code example shown in the previous section.

> Note: You can also use the ``AccountKey/accept(_:)-8wakg`` method directly for visiting a single element.

### Managing Account Values

New ``AccountValues`` instances are created using the ``AccountValuesBuilder`` class. Every container provides access to the respective builder class
using the ``AccountValues/Builder`` typealias.

Below is a short example on how to create a new ``AccountDetails`` instance using the `Builder` class. For more detailed information refer
to the documentation page of ``AccountValuesBuilder``.

```swift
let details = AccountDetails.Builder()
    .set(\.userId, "my-email@example.com")
    .set(\.name, "Hello World")
    .build(owner: /* accountService */)
```

> Note: Building ``AccountDetails`` is special, as you are required to use the dedicated ``AccountValuesBuilder/build(owner:)`` method
    instead of the standard ``AccountValuesBuilder/build()-pqt5`` method.

## Topics

### Generalized Containers

- ``AccountValuesCollection``
- ``AccountValues``

### Account Values

- ``AccountDetails``
- ``SignupDetails``
- ``AccountModifications``
- ``ModifiedAccountDetails``
- ``RemovedAccountDetails``
- ``PartialAccountDetails``

### Account Keys

- ``AccountValues/keys-572sk``
- ``AccountKeyCollection``

### Visitors

- ``AccountValueVisitor``
- ``AcceptingAccountValueVisitor``
- ``AcceptingAccountValueVisitor/acceptAll(_:)-9hgw5``
- ``AccountKeyVisitor``
- ``AcceptingAccountKeyVisitor``
- ``AcceptingAccountKeyVisitor/acceptAll(_:)-1ytax``

### Construction

- ``AccountValuesBuilder``
