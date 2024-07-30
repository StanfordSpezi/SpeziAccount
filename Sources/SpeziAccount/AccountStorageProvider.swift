//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

// TODO: update all docs!


/// A `Module` manages storage of account details.
///
/// Certain ``AccountService`` implementations might be limited to supported only a specific set of ``AccountKey``s
/// (see ``SupportedAccountKeys/exactly(_:)``. If you nonetheless want to use ``AccountKey``s that are unsupported
/// by your ``AccountService``, you can use a `AccountStorageProvider`,
/// inorder to handle storage and retrieval of these additional account values.
public protocol AccountStorageProvider: Module {
    /// Create new associated account data.
    ///
    /// - Note: A call to this method might certainly be immediately followed by a call to ``load(_:_:)``.
    ///
    /// - Parameters:
    ///   - accountId: The primary identifier for stored record.
    ///   - details: The signup details that need to be stored.
    /// - Throws: A `LocalizedError`.
    func create(_ accountId: String, _ details: AccountDetails) async throws

    /// Load associated account data.
    ///
    /// This method is called to load all ``AccountDetails`` that are managed by this `Module`.
    /// This method should retrieve the details from a local cache. If there is nothing found in the local cache and a network request has to be made,
    /// return `nil` and update the details later on by calling ``ExternalAccountStorage/notifyAboutUpdatedDetails(for:_:)``.
    ///
    /// - Important: This method call must return immediately. Use `await` suspension only be for synchronization.
    ///     Return `nil` if you couldn't immediately retrieve the externally stored account details.
    ///
    /// - Parameters:
    ///   - accountId: The primary identifier for stored record.
    ///   - keys: The keys to load.
    /// - Returns: The externally ``AccountDetails`` if they could be loaded instantly (e.g., local cache). Otherwise, if retrieval requires an external network connection,
    ///     return `nil` and supply the account details by calling ``ExternalAccountStorage/notifyAboutUpdatedDetails(for:_:)`` once they arrive.
    /// - Throws: A `LocalizedError`.
    func load(_ accountId: String, _ keys: [any AccountKey.Type]) async throws -> AccountDetails?
    // TODO: doc that async should only be used for synchronization not for waiting for data!

    /// Modify the associated account data of an existing user account.
    ///
    /// This call is used to apply all modifications of the Standard-managed account values.
    ///
    /// - Note: A call to this method might certainly be immediately followed by a call to ``load(_:_:)``.
    ///
    /// - Parameters:
    ///   - accountId: The primary identifier for stored record.
    ///   - modifications: The account modifications.
    /// - Throws: A `LocalizedError`.
    func modify(_ accountId: String, _ modifications: AccountModifications) async throws

    /// Signals the standard the the currently logged in user was removed.
    ///
    /// This method is useful to clear any data of the currently cached user.
    ///
    /// - Parameter accountId: The primary identifier for stored record.
    func disassociate(_ accountId: String) async
    // TODO: doc that async should only be used for synchronization not for waiting for data!

    /// Delete all associated account data.
    ///
    /// - Note: Due to the underlying architecture, there might still be a call to ``clear(_:)`` after a call to
    ///     this method.
    /// - Parameter accountId: The primary identifier for stored record.
    /// - Throws: A `LocalizedError`.
    func delete(_ accountId: String) async throws
}
