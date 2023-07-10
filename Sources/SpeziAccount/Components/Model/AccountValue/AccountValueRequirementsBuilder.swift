//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@resultBuilder
public enum AccountValueRequirementsBuilder {
    public static func buildExpression<Key: AccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
        [AccountValueRequirement<Key>(type: .required)]
    }

    public static func buildExpression<Key: OptionalAccountValueKey>(_ expression: Key.Type) -> [AnyAccountValueRequirement] {
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
        var result: [AnyAccountValueRequirement] = []
        for componentArray in components {
            result.append(contentsOf: componentArray)
        }
        return result
    }
}