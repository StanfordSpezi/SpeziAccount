//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


@resultBuilder
public enum AccountValueRequirementsBuilder {
    public static func buildExpression<Key: RequiredAccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .required)]
    }

    public static func buildExpression<Key: AccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .optional)]
    }

    public static func buildExpression<Key: RequiredAccountValueKey>(_ expression: KeyPath<AccountValueKeys, Key.Type>) -> [AnyAccountValueRequirement] {
        // swiftlint:disable:previous line_length
        [AccountValueRequirement<Key>(type: .required)]
    }

    public static func buildExpression<Key: AccountValueKey>(_ expression: KeyPath<AccountValueKeys, Key.Type>) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .optional)]
    }

    public static func buildBlock(_ components: [AnyAccountValueRequirement]...) -> [AnyAccountValueRequirement] {
        buildArray(components)
    }

    // swiftlint:disable:next discouraged_optional_collection
    public static func buildOptional(_ component: [AnyAccountValueRequirement]?) -> [AnyAccountValueRequirement] {
        component ?? []
    }

    public static func buildEither(first component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    public static func buildEither(second component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    public static func buildLimitedAvailability(_ component: [AnyAccountValueRequirement]) -> [AnyAccountValueRequirement] {
        component
    }

    public static func buildArray(_ components: [[AnyAccountValueRequirement]]) -> [AnyAccountValueRequirement] {
        components.reduce(into: []) { result, requirements in
            result.append(contentsOf: requirements)
        }
    }
}
