# Validation

Generalized input validation abstraction.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

This article provides an overview of all the components used to perform input validation.
They are used across the `SpeziAccount` framework.

The validation state is managed through an instance of ``ValidationEngine``.
You provide a set of ``ValidationRule``s against a given input is validated and the ``ValidationEngine`` provides you
with an array of ``FailedValidationResult``s for all ``ValidationRule``s that failed for a given input.

There are preexisting UI components, like the ``VerifiableTextField``, that perform and display validation results automatically for you. You just have
to manage a ``ValidationEngine`` in the `Environment`.

Below is a short code example, that uses a ``ValidationEngine`` in combination with a ``VerifiableTextField`` to perform a simple non-empty validation
using the preexisting ``ValidationRule/nonEmpty`` rule.
Note how we use the ``ValidationEngine/inputValid`` property to conditionally disable the button input. Further, we ensure validity of input by calling
``ValidationEngine/runValidation(input:)`` on the button press. For more information refer to the documentation of ``ValidationEngine``.
 

```swift
struct MyView: View {
    @StateObject var validation = ValidationEngine(rules: .nonEmpty)

    @State var pet: String = ""

    var body: some View {
        VerifiableTextField("Your favorite pet?", text: $pet)
            .environment(validation)

        Button(action: savePet) {
            Text("Save")
        }
            .disabled(!validation.inputValid)
    }

    func savePet() {
        validation.runValidation(input: pet)
        guard validation.inputValid else {
            return
        }
        // ...
    }
}
```

## Topics

### Validation

- ``ValidationEngine``
- ``ValidationRule``
- ``FailedValidationResult``

### Builtin Validation Rules

- ``ValidationRule/nonEmpty``
- ``ValidationRule/unicodeLettersOnly``
- ``ValidationRule/asciiLettersOnly``
- ``ValidationRule/minimalEmail``
- ``ValidationRule/minimalPassword``
- ``ValidationRule/mediumPassword``
- ``ValidationRule/strongPassword``

### Using Validation in your Views

- ``VerifiableTextField``
- ``ValidationResultsView``

### Collecting Validation Engines

- ``ValidationEngines``
- ``SwiftUI/View/register(engine:with:for:input:)``
- ``SwiftUI/View/register(engine:with:input:)``

### Managed Validation

- ``SwiftUI/View/managedValidation(input:for:rules:)-5gj5g``
- ``SwiftUI/View/managedValidation(input:for:rules:)-zito``
- ``SwiftUI/View/managedValidation(input:rules:)-vp6w``
- ``SwiftUI/View/managedValidation(input:rules:)-8afst``
