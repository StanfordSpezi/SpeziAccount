//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


@resultBuilder
public enum AccountServiceConfigurationBuilder {
    public static func buildExpression<Key: AccountServiceConfigurationKey>(_ expression: Key) -> [any AccountServiceConfigurationKey] {
        [expression]
    }

    public static func buildBlock(_ components: [any AccountServiceConfigurationKey]...) -> [any AccountServiceConfigurationKey] {
        buildArray(components)
    }

    public static func buildEither(first component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    public static func buildEither(second component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    public static func buildOptional(_ component: [any AccountServiceConfigurationKey]?) -> [any AccountServiceConfigurationKey] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    public static func buildLimitedAvailability(_ component: [any AccountServiceConfigurationKey]) -> [any AccountServiceConfigurationKey] {
        component
    }

    public static func buildArray(_ components: [[any AccountServiceConfigurationKey]]) -> [any AccountServiceConfigurationKey] {
        components.reduce(into: []) { result, components in
            result.append(contentsOf: components)
        }
    }
}
