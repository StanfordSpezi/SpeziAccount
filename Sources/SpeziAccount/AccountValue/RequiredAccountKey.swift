//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


/// A typed storage key for values that are required for every user account if used.
///
/// This protocol extends the ``AccountKey`` protocol.
///
/// A `RequiredAccountKey` can be used to provide the guarantee on a type-level that a given account key
/// will be present in every case.
///
/// - Important: When using a ``RequiredAccountKey`` the user is forced to configure it as ``AccountKeyRequirement/required``.
///     But a user might still choose to not configure it at all.
///
/// Use this protocol with care. Accessing the value of a `RequiredAccountKey` when it isn't present,
/// will result in a runtime crash.
///
/// - Important: Avoid introducing required account keys after user accounts have already been created without it.
public protocol RequiredAccountKey: AccountKey, DefaultProvidingKnowledgeSource {} // TODO: 

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
