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
