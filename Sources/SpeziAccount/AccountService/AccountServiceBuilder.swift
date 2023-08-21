//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// A result builder to build a collection of ``AccountService``s.
@resultBuilder
public enum AccountServiceBuilder {
    /// Build a single ``AccountService`` expression.
    public static func buildExpression<Service: AccountService>(_ service: Service) -> [any AccountService] {
        [service]
    }

    /// Build a block of ``AccountService``s.
    public static func buildBlock(_ components: [any AccountService]...) -> [any AccountService] {
        buildArray(components)
    }

    /// Build the first block of an conditional ``AccountService`` component.
    public static func buildEither(first component: [any AccountService]) -> [any AccountService] {
        component
    }

    /// Build the second block of an conditional ``AccountService`` component.
    public static func buildEither(second component: [any AccountService]) -> [any AccountService] {
        component
    }

    /// Build an optional ``AccountService`` component.
    public static func buildOptional(_ component: [any AccountService]?) -> [any AccountService] {
        // swiftlint:disable:previous discouraged_optional_collection
        component ?? []
    }

    /// Build an ``AccountService`` component with limited availability.
    public static func buildLimitedAvailability(_ component: [any AccountService]) -> [any AccountService] {
        component
    }

    /// Build an array of ``AccountService`` components.
    public static func buildArray(_ components: [[any AccountService]]) -> [any AccountService] {
        components.reduce(into: []) { result, services in
            result.append(contentsOf: services)
        }
    }
}
