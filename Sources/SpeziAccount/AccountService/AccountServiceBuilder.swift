//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A result builder to build a collection of ``AccountService``s.
@resultBuilder
public enum AccountServiceBuilder: DependencyCollectionBuilder {
    /// Build a single ``AccountService`` expression.
    public static func buildExpression(_ service: @escaping @autoclosure () -> some AccountService) -> DependencyCollection {
        DependencyCollection(singleEntry: service)
    }
}
