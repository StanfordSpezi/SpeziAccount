//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A result builder to build a collection of ``AnyAccountValueRequirement``s.
@resultBuilder
public enum AccountValueRequirementsBuilder {
    /// Build a single ``RequiredAccountValueKey`` expression by supplying the key type.
    public static func buildExpression<Key: RequiredAccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .required)]
    }

    /// Build a single ``AccountValueKey`` expression by supplying the key type.
    public static func buildExpression<Key: AccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .optional)]
    }

    /// Build a single ``RequiredAccountValueKey`` expression by supplying a KeyPath.
    public static func buildExpression<Key: RequiredAccountValueKey>(_ expression: KeyPath<AccountValueKeys, Key.Type>) -> [AnyAccountValueRequirement] {
        // swiftlint:disable:previous line_length
        [AccountValueRequirement<Key>(type: .required)]
    }

    /// Build a single ``AccountValueKey`` expression by supplying a KeyPath.
    public static func buildExpression<Key: AccountValueKey>(_ expression: KeyPath<AccountValueKeys, Key.Type>) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .optional)]
    }

    /// Build a block of ``AnyAccountValueRequirement``s.
    public static func buildBlock(_ components: [AnyAccountValueRequirement]...) -> [AnyAccountValueRequirement] {
        buildArray(components)
    }

    /// Build the first block of an conditional ``AnyAccountValueRequirement`` component.
    public static func buildEither(first component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    /// Build the second block of an conditional ``AnyAccountValueRequirement`` component.
    public static func buildEither(second component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    /// Build an optional ``AnyAccountValueRequirement`` component.
    public static func buildOptional(_ component: [AnyAccountValueRequirement]?) -> [AnyAccountValueRequirement] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an ``AnyAccountValueRequirement`` component with limited availability.
    public static func buildLimitedAvailability(_ component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    /// Build an array of ``AnyAccountValueRequirement``s.
    public static func buildArray(_ components: [[AnyAccountValueRequirement]]) -> [AnyAccountValueRequirement] {
        components.reduce(into: []) { result, requirements in
            result.append(contentsOf: requirements)
        }
    }
}
