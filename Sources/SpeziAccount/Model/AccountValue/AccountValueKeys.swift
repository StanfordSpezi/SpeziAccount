//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// A collection of ``AccountValueKeys`` type instances.
///
/// This type is used across ``SpeziAccount`` API to easily and intuitively access the metatype of an ``AccountValueKey``.
///
/// Below is a short example creating a ``AccountServiceConfiguration`` demonstrating the use of `KeyPath`-based access
/// to the metatype of an ``AccountValueKey``.
///
/// ```swift
/// AccountServiceConfiguration(name: "TestEmailPasswordAccountService") {
///     FieldValidationRules(for: \.password, rules: .interceptingChain(.nonEmpty), .strongPassword)
/// }
/// ```
public struct AccountValueKeys {
    private init() {}
}
