# Customize your View Styles

Customize how your Account Service appears in the ``AccountSetup`` view.

<!--
                  
This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

## Overview

``AccountSetupViewStyle``s are used to present your Account Service implementation to the user in the ``AccountSetup`` view.
For some Views default implementations are provided based on the ``AccountServiceConfiguration`` (e.g. using the ``AccountServiceName`` or ``AccountServiceImage``)
or based on the type of Account Service used.

For more information refer to the documentation of ``AccountSetupViewStyle``, ``EmbeddableAccountSetupViewStyle``, ``UserIdPasswordAccountSetupViewStyle``,
or ``IdentityProviderViewStyle``.

## Topics 

### Designing Account Setup Views

- ``AccountSetupViewStyle``
- ``EmbeddableAccountSetupViewStyle``
- ``UserIdPasswordAccountSetupViewStyle``
- ``IdentityProviderViewStyle``

### Reusable UI Components

TODO topics on account setup?
- ``DefaultAccountSetupHeader``
- ``AccountSummaryBox``
- ``SignupForm``
- ``DateOfBirthPicker``
- ``GenderIdentityPicker``
- ``SuccessfulPasswordResetView``

### UI Components for an UserIdPasswordAccountService

- ``UserIdPasswordPrimaryView``
- ``UserIdPasswordEmbeddedView``
- ``UserIdPasswordResetView``
