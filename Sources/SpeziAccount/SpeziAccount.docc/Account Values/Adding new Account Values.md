# Supporting new Types of Account Details

Support new user account details by defining your own `AccountKey`.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

By defining a custom ``AccountKey`` you can support storing custom data points with your user accounts.
An `AccountKey` declaration provides useful meta-data information (like name, a category and a initial value) and defines user interface components
for data entry (see ``DataEntryView``) and displaying data (using ``DataDisplayView``). For some types of account values these views can be automatically
substituted.

This articles guides you through all the necessary steps to declare your custom `AccountKey`.

### Declaring the property

You use the ``AccountKey(name:category:as:initial:displayView:entryView:)`` macro to declare a new ``AccountKey``.

It is mandatory to provide a localizable ``AccountKey/name`` and the `Value` type.
> Note: Refer to `Value Conformances` section below to learn more of the mandatory conformances for the `Value` type. 

Optionally, you might want to customize the ``AccountKey/category`` in which the account details are shown (see ``AccountKeyCategory``).
An ``AccountKey/initialValue-6h1oo`` might be required, depending on the `Value` type if `SpeziAccount` cannot derive a sensible default
(e.g., SpeziAccount automatically provides an ``InitialValue/empty(_:)`` String for String-based account keys).

Below is a short code example that adds support to store a string-based biography that a user might show on their profile.

```swift
extension AccountDetails {
    @AccountKey(name: "Biography", category: .personalDetails, as: String.self)
    var biography: String?
}
```


In order to be able to refer to your account key, you need to add a entry to the ``AccountKeys`` using the ``KeyEntry(_:)`` macro.

```swift
@KeyEntry(\.biography)
extension AccountKeys {}
```

### Customize User Interfaces

While SpeziAccount tries as best as it can to automatically provide user interfaces to display and edit your custom account keys,
it might be necessary or improve the user experience to provide your own user interfaces.

This is done by implementing a ``DataDisplayView`` or ``DataEntryView`` respectively.

- Note: The `User Interfaces that are provided by default` section provides an overview when SpeziAccount is able to provide default user interfaces.

The code example below implements a custom `EntryView` and `DisplayView` and updates the `AccountKey` declaration from above to use
the new views.

```swift
import SpeziAccount
import SpeziValidation
import SpeziViews
import SwiftUI


/// A custom data entry view that disables auto-correction for the biography key.
private struct EntryView: DataEntryView {
    @Binding private var biography: Value

    var body: some View {
        VerifiableTextField("enter biography", text: $biography)
            .autocorrectionDisabled()
            .lineLimit(2...5)
    }

    init(_ value: Binding<Value>) {
        self._biography = value
    }
}


/// A custom data display view that allows to display up to 3 lines of the biography.
private struct DisplayView: DataDisplayView {
    private let value: String

    var body: some View {
        Text(value)
            .lineLimit(...3) // show biography in max 3 lines
    }

    init(_ value: String) {
        self.value = value
    }
}


// the updated @AccountKey macro definition from above
extension AccountDetails {
    @AccountKey(
        name: "Biography",
        category: .personalDetails,
        as: String.self,
        displayView: DisplayView.self,
        entryView: EntryView.self
    )
    var biography: String?
}
```

- Note: You may have to manually handle input validation. Refer to the `Input Validation` section below.

### Value Conformances

Your `Value` type requires several protocol conformances.

* The `Value` type must conform to [`Sendable`](https://developer.apple.com/documentation/swift/sendable)) to be safely passed across actor boundaries.
* The `Value` type must conform to [`Equatable`](https://developer.apple.com/documentation/swift/equatable)) to be easily notified about changes at data entry.
* The `Value` type must conform to [`Codable`](https://developer.apple.com/documentation/swift/codable) such that an ``AccountService``s or an ``AccountStorageProvider``
can easily store and retrieve arbitrary `Value` types.

### User Interfaces that are provided by default

This section briefly highlights the conditions under which SpeziAccount can provide user interface components automatically.

A ``AccountKey/DataDisplay`` view is automatically provided if:
* The `Value` is of type `String`.
* The `Value` conforms to [CustomLocalizedStringResourceConvertible](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible),
    providing a localized string-representation.
* The `Value` is a [FixedWidthInteger](https://developer.apple.com/documentation/swift/fixedwidthinteger).

A ``AccountKey/DataEntry`` view is automatically provide if:
* The `Value` is of type `String`.
    A simple string entry will appear. You have to implement your own view if you have special formatting requirements.
* The `Value` is a [FixedWidthInteger](https://developer.apple.com/documentation/swift/fixedwidthinteger).
    A simple number entry will appear. You have to implement your own view if you have special formatting requirements.
* The `Value` conforms to the ``PickerValue`` protocols. This is provides a Picker UI for enum types.
    `PickerValue` is shorthand to conform to the [`CaseIterable`](https://developer.apple.com/documentation/swift/caseiterable),
    [`CustomLocalizedStringResourceConvertible`](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible)
    and [`Hashable`](https://developer.apple.com/documentation/swift/hashable) protocols.

### Input Validation

Input validation relies on the [SpeziValidation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezivalidation) package.

`SpeziAccount` provides basic validation for most cases where necessary due to ``FieldValidationRules`` or ``AccountKeyRequirement`` configurations.
Still, you are required to evaluate to which extent validation has to be handled in your implementation.

* For all `String`-based types validation is automatically managed. Validation is either configured based on
    the rules provided by the account service through ``FieldValidationRules`` or if the user specified a ``AccountKeyRequirement/required`` level.
    If not using default components like [`VerifiableTextField`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezivalidation/verifiabletextfield)),
    you need to visualize validation results yourself using the [`ValidationEngine`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezivalidation/validationengine))
    in the environment.
* For other types that use ``InitialValue/empty(_:)`` and are specified to be ``AccountKeyRequirement/required``,
    validation is automatically set up to check if the user provided a value. For example given a `Date`-based account value, we would require that
    the user modifies the Data at least once.
* For other types that use ``InitialValue/default(_:)`` we do not perform any validation automatically.
* If you have diverging needs (e.g., multi field input), you will need to handle validation yourself.


## Topics

### Implementing Account Values

- ``AccountKey``
- ``RequiredAccountKey``
- ``AccountKeyCategory``
- ``InitialValue``
- ``AccountKeys``

### Data Display View

- ``DataDisplayView``
- ``StringBasedDisplayView``
- ``LocalizableStringBasedDisplayView``

### Data Entry View

- ``DataEntryView``
- ``GeneralizedDataEntryView``

### Available Environment Keys

- ``SwiftUI/EnvironmentValues/accountViewType``
- ``SwiftUI/EnvironmentValues/passwordFieldType``
- ``SwiftUI/EnvironmentValues/accountServiceConfiguration``
- ``AccountViewType``
- ``OverviewEntryMode``
