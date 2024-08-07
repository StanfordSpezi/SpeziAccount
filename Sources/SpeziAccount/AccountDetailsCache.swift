//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziLocalStorage


/// Locally cache account details on disk.
///
/// This `Module` allows to cache account details locally on disk.
/// This is useful for ``AccountStorageProvider`` that want to keep a local copy of their account details to avoid needing to contact the remote server,
/// especially important in situations where the app is started without any internet connectivity.
public actor AccountDetailsCache: Module, DefaultInitializable {
    @Application(\.logger)
    private var logger

    @Dependency private var localStorage = LocalStorage()

    /// In-memory cache to avoid contacting the disk too often.
    private var localCache: [String: AccountDetails] = [:]


    public init() {}

    private static func key(for accountId: String) -> String {
        "edu.stanford.spezi.details-cache.\(accountId)"
    }

    /// Retrieve an entry from the cache.
    ///
    /// - Parameters:
    ///   - accountId: The accountId for which the entry should be retrieved.
    ///   - keys: The ``AccountKey``s to retrieve and decode.
    /// - Returns: Returns the locally cached account details or `nil` if nothing was cached.
    public func loadEntry(for accountId: String, _ keys: [any AccountKey.Type]) -> AccountDetails? {
        if let details = localCache[accountId] {
            return details
        }

        let decoder = JSONDecoder()
        decoder.userInfo[.accountDetailsKeys] = keys

        do {
            let details = try localStorage.read(
                AccountDetails.self,
                decoder: decoder,
                storageKey: Self.key(for: accountId),
                settings: .encryptedUsingKeyChain(userPresence: false, excludedFromBackup: false)
            )

            localCache[accountId] = details
            return details
        } catch {
            if let cocoaError = error as? CocoaError,
               cocoaError.code == .fileNoSuchFile {
                return nil // we are fine if it doesn't exist
            }
            logger.error("Failed to read cached account details from disk: \(error)")
        }

        return nil
    }

    /// Clear a cache entry for an account.
    ///
    /// - Parameter accountId: The accountId for which to clear the cache.
    public func clearEntry(for accountId: String) {
        localCache.removeValue(forKey: accountId)
        do {
            try localStorage.delete(storageKey: Self.key(for: accountId))
        } catch {
            logger.error("Failed to clear cached account details from disk: \(error)")
        }
    }

    /// Communicate modifications done by the user.
    ///
    /// Call this method, whenever the user changes their account details.
    /// - Note: This method is called by describing what is changed. If just want to overwrite the existing entry use ``communicateRemoteChanges(for:_:)``.
    ///
    /// - Parameters:
    ///   - accountId: The accountId for which changes were made.
    ///   - modifications: The changes done by the user.
    public func communicateModifications(for accountId: String, _ modifications: AccountModifications) {
        // make sure our cache is consistent
        var details = AccountDetails()
        if let cached = localCache[accountId] {
            details.add(contentsOf: cached)
        }
        details.add(contentsOf: modifications.modifiedDetails, merge: true)
        details.removeAll(modifications.removedAccountKeys)

        communicateRemoteChanges(for: accountId, details)
    }

    /// Communicate update account details.
    ///
    /// Call this method, if you have a complete new source of truth for the account details.
    /// A call to this method completely replaces the cached account details.
    ///
    /// - Note: If you instead have a description of modifications using ``AccountModifications``, use the ``communicateModifications(for:_:)`` method instead.
    ///
    /// - Parameters:
    ///   - accountId: the accountId for which changes were made.
    ///   - details: The updated account details.
    public func communicateRemoteChanges(for accountId: String, _ details: AccountDetails) {
        localCache[accountId] = details

        do {
            try localStorage.store(
                details,
                storageKey: Self.key(for: accountId),
                settings: .encryptedUsingKeyChain(userPresence: false, excludedFromBackup: false)
            )
        } catch {
            logger.error("Failed to update cached account details to disk: \(error)")
        }
    }
}
