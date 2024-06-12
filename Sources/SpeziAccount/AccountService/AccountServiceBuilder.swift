//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO: dependency builder
/*
 import Spezi

 /// A result builder to build a ``DependencyCollection``.
@resultBuilder
public enum AccountServiceBuilder: DependencyCollectionBuilder {
    /// An auto-closure expression, providing the default dependency value, building the ``DependencyCollection``.
    public static func buildExpression<Service: AccountService & Module>(_ expression: @escaping @autoclosure () -> M) -> DependencyCollection {
        DependencyCollection(DependencyContext(defaultValue: expression))
    }
}
 */
import Spezi

/// A result builder to build a collection of ``AccountService``s.
@resultBuilder
public enum AccountServiceBuilder: DependencyCollectionBuilder {
    /// Build a single ``AccountService`` expression.
    public static func buildExpression<Service: AccountService & Module>(_ service: Service) -> DependencyCollection {
        DependencyCollection {
            service
        }
    }
}
