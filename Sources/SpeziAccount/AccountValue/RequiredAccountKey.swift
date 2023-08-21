//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


// TODO communicate the nunace, if it is used it is set to be required! But it doesn't need to be used!

/// A typed storage key extending ``AccountKey`` for values that are required for every user account.
///
/// A `RequiredAccountKey` can be used to provide the guarantee on a type-level that a given account key
/// will be present in every case.
///
/// - Important: Use this protocol with care. Accessing the value of a `RequiredAccountKey` when it isn't
///     present, will result in a runtime crash.
///     When you introduce a new required account key after user accounts have already been created without it,
///     make sure to use optional bindings by directly accessing ``AccountValues/storage`` to safely
///     unwrap the value.
public protocol RequiredAccountKey: AccountKey, DefaultProvidingKnowledgeSource {}

extension RequiredAccountKey {
    /// A default implementation that results in a fatal error.
    ///
    /// - Important: While the ``RequiredAccountKey`` conforms to `DefaultProvidingKnowledgeSource` in carries
    ///     inherently different meaning and just relies on the fact that accessors for `DefaultProvidingKnowledgeSource`
    ///     return a non-optional `Value`.
    public static var defaultValue: Value {
        preconditionFailure("""
                            The required account key \(Self.self) was tried to be accessed but wasn't provided! \
                            Please verify your `AccountConfiguration` or the implementation of your `AccountService`.
                            """)
    }
}
