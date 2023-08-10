//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A typed storage key extending ``AccountValueKey`` for values that are required for every user account.
///
/// A `RequiredAccountValueKey` can be used to provide the guarantee on a type-level that a given account value
/// will be present in every case.
///
/// - Important: Use this protocol with care. Accessing the value of a `RequiredAccountValueKey` when it isn't
///     present, will result in a runtime crash.
///     When you introduce a new required account value after user accounts have already been created without it,
///     make sure to use optional bindings by directly accessing ``AccountValueStorageContainer/storage`` to safely
///     unwrap the value.
public protocol RequiredAccountValueKey: AccountValueKey, DefaultProvidingKnowledgeSource {}

extension RequiredAccountValueKey {
    /// A default implementation that results in a fatal error.
    ///
    /// - Important: While the ``RequiredAccountValueKey`` conforms to `DefaultProvidingKnowledgeSource` in carries
    ///     inherently different meaning and just relies on the fact that accessors for `DefaultProvidingKnowledgeSource`
    ///     return a non-optional `Value`.
    public static var defaultValue: Value {
        preconditionFailure("""
                            A required AccountValue wasn't provided by the respective AccountService! \
                            Something went wrong with checking the requirements.
                            """)
    }
}
