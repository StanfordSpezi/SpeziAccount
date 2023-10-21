//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A `Spezi` Standard that manages data flow of additional account values.
///
/// Certain ``AccountService`` implementations might be limited to supported only a specific set of ``AccountKey``s
/// (see ``SupportedAccountKeys/exactly(_:)``. If you nonetheless want to use ``AccountKey``s that are unsupported
/// by your ``AccountService``, you may add an implementation of the `AccountStorageStandard` protocol to your App's `Standard`,
/// inorder to handle storage and retrieval of these additional account values.
///
/// - Note: You can use the ``Spezi/Standard/AccountReference`` property wrapper to get access to the global ``Account`` object if you need it to implement additional functionality.
public protocol AccountStorageStandard: Standard {
    /// Create new associated account data.
    ///
    /// - Note: A call to this method might certainly be immediately followed by a call to ``load(_:_:)``.
    ///
    /// - Parameters:
    ///   - identifier: The primary identifier for stored record.
    ///   - details: The signup details that need to be stored.
    /// - Throws: A `LocalizedError`.
    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws

    /// Load associated account data.
    ///
    /// This method is called to load all ``AccountDetails`` that are managed by this `Standard`.
    ///
    /// - Note: It is advised to maintain a local cache for the stored ``AccountDetails`` to maintain
    ///     easy and fast retrieval. Make sure the local data is maintained throughout operations like
    ///     ``create(_:_:)`` and ``modify(_:_:)`` while also accounting for updates in the remote storage.
    ///
    ///
    /// - Parameters:
    ///   - identifier: The primary identifier for stored record.
    ///   - keys: The keys to load.
    /// - Parameter userId: The userId to load data for.
    /// - Returns: The assembled ``PartialAccountDetails`` (see ``AccountValuesBuilder``).
    /// - Throws: A `LocalizedError`.
    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails

    /// Modify the associated account data of an existing user account.
    ///
    /// This call is used to apply all modifications of the Standard-managed account values.
    ///
    /// - Note: A call to this method might certainly be immediately followed by a call to ``load(_:_:)``.
    ///
    /// - Parameters:
    ///   - identifier: The primary identifier for stored record.
    ///   - modifications: The account modifications.
    /// - Throws: A `LocalizedError`.
    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws

    /// Signals the standard the the currently logged in user was removed.
    ///
    /// This method is useful to clear any data of the currently cached user.
    ///
    /// - Parameter identifier: The primary identifier for stored record.
    func clear(_ identifier: AdditionalRecordId) async

    /// Delete all associated account data.
    ///
    /// - Note: Due to the underlying architecture, there might still be a call to ``clear(_:)`` after a call to
    ///     this method.
    /// - Parameter identifier: The primary identifier for stored record.
    /// - Throws: A `LocalizedError`.
    func delete(_ identifier: AdditionalRecordId) async throws
}


extension Standard {
    /// A property wrapper that can be used within `Standard` instances to request
    /// access to the global ``Account`` instance.
    ///
    /// Below is a short code example on how to use this property wrapper:
    /// ```swift
    /// public actor MyStandard: AccountStorageStandard {
    ///     @AccountReference var account
    /// }
    /// ```
    public typealias AccountReference = _WeakInjectable<Account>
}
