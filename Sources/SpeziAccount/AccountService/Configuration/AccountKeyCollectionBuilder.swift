//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A result builder to build a collection of ``AccountValueKey`` metatypes.
@resultBuilder
public enum AccountKeyCollectionBuilder {
    /// Build a single ``AccountValueKey`` metatype expression using `KeyPath` notation.
    public static func buildExpression<Key: AccountValueKey>(_ expression: KeyPath<AccountValueKeys, Key.Type>) -> [any AccountValueKey.Type] {
        [Key.self]
    }

    /// Build a block of ``AccountValueKey`` metatypes.
    public static func buildBlock(_ components: [any AccountValueKey.Type]...) -> [any AccountValueKey.Type] {
        buildArray(components)
    }

    /// Build the first block of an conditional ```AccountValueKey`` metatype component.
    public static func buildEither(first component: [any AccountValueKey.Type]) -> [any AccountValueKey.Type] {
        component
    }

    /// Build the second block of an conditional ``AccountValueKey`` metatype component.
    public static func buildEither(second component: [any AccountValueKey.Type]) -> [any AccountValueKey.Type] {
        component
    }

    /// Build an optional ``AccountValueKey`` metatype component.
    public static func buildOptional(_ component: [any AccountValueKey.Type]?) -> [any AccountValueKey.Type] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an ``AccountValueKey`` metatype component with limited availability.
    public static func buildLimitedAvailability(_ component: [any AccountValueKey.Type]) -> [any AccountValueKey.Type] {
        component
    }

    /// Build an array of ``AccountValueKey`` metatype components.
    public static func buildArray(_ components: [[any AccountValueKey.Type]]) -> [any AccountValueKey.Type] {
        components.reduce(into: []) { result, components in
            result.append(contentsOf: components)
        }
    }
}
