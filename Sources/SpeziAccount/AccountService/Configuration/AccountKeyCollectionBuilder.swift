//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A result builder to build a collection of ``AccountKeyWithDescription`` metatypes.
@resultBuilder
public enum AccountKeyCollectionBuilder {
    /// Build a single ``AccountKeyWithDescription`` metatype expression using `KeyPath` notation.
    public static func buildExpression<Key: AccountKey>(_ expression: KeyPath<AccountKeys, Key.Type>) -> [any AccountKeyWithDescription] {
        [AccountKeyWithKeyPathDescription(expression)]
    }

    /// Build a block of ``AccountKeyWithDescription`` metatypes.
    public static func buildBlock(_ components: [any AccountKeyWithDescription]...) -> [any AccountKeyWithDescription] {
        buildArray(components)
    }

    /// Build the first block of an conditional ``AccountKeyWithDescription`` metatype component.
    public static func buildEither(first component: [any AccountKeyWithDescription]) -> [any AccountKeyWithDescription] {
        component
    }

    /// Build the second block of an conditional ``AccountKeyWithDescription`` metatype component.
    public static func buildEither(second component: [any AccountKeyWithDescription]) -> [any AccountKeyWithDescription] {
        component
    }

    /// Build an optional ``AccountKeyWithDescription`` metatype component.
    public static func buildOptional(_ component: [any AccountKeyWithDescription]?) -> [any AccountKeyWithDescription] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an ``AccountKeyWithDescription`` metatype component with limited availability.
    public static func buildLimitedAvailability(_ component: [any AccountKeyWithDescription]) -> [any AccountKeyWithDescription] {
        component
    }

    /// Build an array of ``AccountKeyWithDescription`` metatype components.
    public static func buildArray(_ components: [[any AccountKeyWithDescription]]) -> [any AccountKeyWithDescription] {
        components.reduce(into: []) { result, components in
            result.append(contentsOf: components)
        }
    }
}
