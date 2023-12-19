<!--

This source file is part of the Spezi open-source project.

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi Account

[![Build and Test](https://github.com/StanfordSpezi/SpeziAccount/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziAccount/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziAccount/branch/main/graph/badge.svg?token=IAfXOmGenQ)](https://codecov.io/gh/StanfordSpezi/SpeziAccount)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7796499.svg)](https://doi.org/10.5281/zenodo.7796499)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziAccount%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziAccount)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziAccount%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziAccount)

A Spezi framework that provides account-related functionality including login, sign up and password reset.

## Overview

The `SpeziAccount` framework fully abstracts setup and management of user account functionality for the
[Spezi](https://github.com/StanfordSpezi/Spezi/) framework ecosystem.

|![Screenshot displaying the account setup view with an email and password prompt and a Sign In with Apple button.](Sources/SpeziAccount/SpeziAccount.docc/Resources/AccountSetup.png#gh-light-mode-only) ![Screenshot displaying the account setup view with an email and password prompt and a Sign In with Apple button.](Sources/SpeziAccount/SpeziAccount.docc/Resources/AccountSetup~dark.png#gh-dark-mode-only)|![Screenshot displaying the Signup Form for Account setup.](Sources/SpeziAccount/SpeziAccount.docc/Resources/SignupForm.png#gh-light-mode-only) ![Screenshot displaying the Signup Form for Account setup.](Sources/SpeziAccount/SpeziAccount.docc/Resources/SignupForm~dark.png#gh-dark-mode-only)|![Screenshot displaying the Account Overview.](Sources/SpeziAccount/SpeziAccount.docc/Resources/AccountOverview.png#gh-light-mode-only) ![Screenshot displaying the Account Overview.](Sources/SpeziAccount/SpeziAccount.docc/Resources/AccountOverview~dark.png#gh-dark-mode-only)|
|:--:|:--:|:--:|
|The [`AccountSetup`](https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/accountsetup) is the central view for account onboarding, facilitating account login and creation. |The [`SignupForm`](https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/signupform) is used by email-password-based AccountServices by default. |The [`AccountOverview`](https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/accountoverview) is used to view and modify the user details of the currently associated account.|


The ``AccountSetup`` and ``AccountOverview`` views are central to `SpeziAccount`.
You use the ``AccountDetails`` abstraction within your views to visualize account information of the associated user account.

An ``AccountService`` provides an abstraction layer for managing different types of account management services
(e.g., email address and password-based service combined with an identity provider like Sign in with Apple).

For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziAccount/documentation).

> [!NOTE]
> The [SpeziFirebase](https://swiftpackageindex.com/StanfordSpezi/SpeziFirebase/documentation/spezifirebaseaccount)
framework provides the `FirebaseAccountConfiguration` you can use to configure an Account Service base on the Google Firebase service.

## Setup

You need to add the Spezi Account Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]  
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.

The [Initial Setup](https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/initial-setup)
article provides a quick-start guide to set up `SpeziAccount` in your App.
Refer to the
[Creating your own Account Service](https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/creating-your-own-account-service)
article if you plan on implementing your own Account Service.

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the Spezi Account module.

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziAccount/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer~dark.png#gh-dark-mode-only)
