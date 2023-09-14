//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A result builder to build a collection of ``AccountServiceConfigurationKey``s.
@resultBuilder
public enum AccountServiceConfigurationBuilder {
    /// Build a single ``AccountServiceConfigurationKey`` expression.
    public static func buildExpression<Key: AccountServiceConfigurationKey>(_ expression: Key) -> [any AccountServiceConfigurationKey] {
        [expression]
    }

    /// Build a block of ``AccountServiceConfigurationKey``s.
    public static func buildBlock(_ components: [any AccountServiceConfigurationKey]...) -> [any AccountServiceConfigurationKey] {
        buildArray(components)
    }

    /// Build the first block of an conditional ``AccountServiceConfigurationKey`` component.
    public static func buildEither(first component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    /// Build the second block of an conditional ``AccountServiceConfigurationKey`` component.
    public static func buildEither(second component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    /// Build an optional ``AccountServiceConfigurationKey`` component.
    public static func buildOptional(_ component: [any AccountServiceConfigurationKey]?) -> [any AccountServiceConfigurationKey] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an ``AccountServiceConfigurationKey`` component with limited availability.
    public static func buildLimitedAvailability(_ component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    /// Build an array of ``AccountServiceConfigurationKey`` components.
    public static func buildArray(_ components: [[any AccountServiceConfigurationKey]]) -> [any AccountServiceConfigurationKey] {
        components.reduce(into: []) { result, components in
            result.append(contentsOf: components)
        }
    }
}
