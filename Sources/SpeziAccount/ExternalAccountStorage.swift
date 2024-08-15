//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


/// Interact with an external storage provider.
///
/// Some ``AccountService`` implementations might not support storing arbitrary ``AccountDetails``. Therefore, it is required to store these additional account details using an
/// external ``AccountStorageProvider``.
/// This module is used to interact with an external storage provider.
///
/// ## Topics
///
/// ### Interacting with a Storage Provider
/// - ``updatedDetails``
/// - ``requestExternalStorage(of:for:)``
/// - ``updateExternalStorage(with:for:)``
/// - ``retrieveExternalStorage(for:_:)-8gbg``
/// - ``retrieveExternalStorage(for:_:)-8zvkq``
///
/// ### Communicate changes as a Storage Provider
/// - ``notifyAboutUpdatedDetails(for:_:)``
public final class ExternalAccountStorage {
    /// Capture details that are externally stored, associated with their account id.
    public struct ExternallyStoredDetails: Sendable {
        /// The account id the storage details are associated with.
        ///
        /// Fore more information refer to ``AccountDetails/accountId``.
        public let accountId: String
        /// The details that are stored externally.
        public let details: AccountDetails
    }

    private nonisolated(unsafe) weak var storageProvider: (any AccountStorageProvider)?

    private nonisolated(unsafe) var subscriptions: [UUID: AsyncStream<ExternallyStoredDetails>.Continuation] = [:]
    private let lock = NSLock()


    /// Subscribe to updated details received from the storage provider.
    ///
    /// A storage provider might notify the storage module of externally modified account details (e.g., a user modifying their details from another system).
    /// This async stream yields all updated details received from the external storage provider via ``notifyAboutUpdatedDetails(for:_:)``.
    public var updatedDetails: AsyncStream<ExternallyStoredDetails> {
        AsyncStream { continuation in
            let id = UUID()
            lock.withLock {
                subscriptions[id] = continuation
            }
            continuation.onTermination = { [weak self] _ in
                guard let self else {
                    return
                }
                lock.withLock {
                    self.subscriptions[id] = nil
                }
            }
        }
    }

    init(_ storageProvider: (any AccountStorageProvider)?) {
        self.storageProvider = storageProvider
    }

    /// Notify the account service about changes in the external record.
    ///
    /// This method is called by the ``AccountStorageProvider`` to notify the ``AccountService`` that the externally stored records changed, e.g., due to a change
    /// in an external system.
    ///
    /// - Note: The `AccountService` can use the ``updatedDetails`` stream to subscribe to receiving updated account details.
    ///
    /// - Parameters:
    ///   - accountId: The account id for which details changed.
    ///   - details: All externally stored account details with updated values.
    public func notifyAboutUpdatedDetails(for accountId: String, _ details: AccountDetails) {
        var details = details
        details.isIncomplete = false
        let update = ExternallyStoredDetails(accountId: accountId, details: details)

        lock.withLock {
            for continuation in subscriptions.values {
                continuation.yield(update)
            }
        }
    }

    /// Request external storage of account details.
    ///
    /// - Parameters:
    ///   - details: The set of account values that need to be stored externally.
    ///   - accountId: The account id with which the details are associated.
    public func requestExternalStorage(of details: AccountDetails, for accountId: String) async throws {
        guard !details.isEmpty else {
            return
        }

        guard let storageProvider else {
            preconditionFailure("An External AccountStorageProvider was assumed to be present. However no provider was configured.")
        }

        try await storageProvider.store(accountId, details)
    }


    /// Retrieve externally stored account details.
    ///
    /// - Important: Subscribe to changes from the storage provider using the ``updatedDetails`` async stream.
    ///
    /// - Parameters:
    ///   - accountId: The account id for which account details should be retrieved from the external storage.
    ///   - keys: The list of keys that are known to be stored externally.
    /// - Returns: The account details retrieved from the external storage. In the case that the details are not yet loaded, the ``AccountDetails/isIncomplete`` flag is
    ///     set and shall be merged into the details the account service aims to supply. Make sure to not persistently store these account details containing the ``AccountDetails/isIncomplete``
    ///     flag set to true.
    public func retrieveExternalStorage(for accountId: String, _ keys: [any AccountKey.Type]) async throws -> AccountDetails {
        guard !keys.isEmpty else {
            return AccountDetails()
        }
        
        guard let storageProvider else {
            preconditionFailure("An External AccountStorageProvider was assumed to be present. However no provider was configured.")
        }

        guard let details = try await storageProvider.load(accountId, keys) else {
            // the storage provider currently doesn't have a local copy, they will notify us with updated details later on
            var details = AccountDetails()
            details.isIncomplete = true
            return details
        }

        return details
    }

    /// Retrieve externally stored account details.
    ///
    /// - Parameters:
    ///   - accountId: The account id for which account details should be retrieved from the external storage.
    ///   - keys: The list of keys that are known to be stored externally.
    @_disfavoredOverload
    public func retrieveExternalStorage<Keys: AcceptingAccountKeyVisitor>(for accountId: String, _ keys: Keys) async throws -> AccountDetails {
        try await retrieveExternalStorage(for: accountId, keys._keys)
    }


    /// Update an externally stored record.
    ///
    /// - Parameters:
    ///   - modifications: The modifications that need to be applied to the existing record.
    ///   - accountId: The account id with which the details are associated with.
    public func updateExternalStorage(with modifications: AccountModifications, for accountId: String) async throws {
        guard let storageProvider else {
            preconditionFailure("An External AccountStorageProvider was assumed to be present. However no provider was configured.")
        }

        try await storageProvider.store(accountId, modifications)
    }

    @MainActor
    func willDeleteAccount(for accountId: String) async throws {
        try await storageProvider?.delete(accountId)
    }

    func userWillDisassociate(for accountId: String) async {
        await storageProvider?.disassociate(accountId)
    }
}


extension ExternalAccountStorage: Module, Sendable {}
