//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


public final class ExternalAccountStorage {
    public struct ExternallyStoredDetails {
        public let accountId: String
        public let details: AccountDetails
    }

    private nonisolated(unsafe) weak var storageProvider: (any AccountStorageProvider)?

    private nonisolated(unsafe) var subscriptions: [UUID: AsyncStream<ExternallyStoredDetails>.Continuation] = [:]
    private let lock = NSLock()

    public var detailUpdates: AsyncStream<ExternallyStoredDetails> { // TODO: think about name!
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
                    self.subscriptions[id] = nil // TODO: no need to finish right?
                }
            }
        }
    }

    init(_ storageProvider: (any AccountStorageProvider)?) {
        self.storageProvider = storageProvider
    }


    public convenience init() {
        self.init(nil)
    }

    public func notifyAboutUpdatedDetails(for accountId: String, _ details: AccountDetails) { // TODO: think about name!
        let update = ExternallyStoredDetails(accountId: accountId, details: details)

        lock.withLock {
            for continuation in subscriptions.values {
                continuation.yield(update)
            }
        }
    }

    // Service -> Storage
    // TODO: signal disassociation of user (clear cache and snapshot listener?)
    // TODO: loadAll (e.g., login => locally cache data and register snapshot listener)
    //    => load should be sync! either you have something cached or you tell use later what the details are (all account keys are optional anyways?)
    //    => do we need to mark the account details incomplete?
    // TODO: create: signal fresh creation (maybe default implementation that overloads to modify? or maybe not, you can do that yourself)
    // TODO: modification: (e.g., removed vs updated details)
    // TODO: delete: delete the whole user record

    // Storage -> Service
    // TODO: notification about updated user details!

    public func requestExternalStorage(of details: AccountDetails, for accountId: String) async throws {

        // TODO: store additional details after signup
        guard !details.isEmpty else {
            return
        }

        guard let storageProvider else {
            // TODO: any earlier point to tell them about misconfiguration?
            preconditionFailure("Requested to store stuff, but nothing found!")
        }

        try await storageProvider.create(accountId, details)
    }


    public func retrieveExternalStorage(for accountId: String, _ keys: [any AccountKey.Type]) async throws -> AccountDetails {
        guard !keys.isEmpty else {
            return AccountDetails()
        }
        
        // TODO: previously we calculcated the keys we were required to source from external source like below:
        /*
         let unsupportedKeys = accountService.configuration
         .unsupportedAccountKeys(basedOn: configuration)
         .map { $0.key }
         */
        guard let storageProvider else {
            // TODO: any earlier point to tell them about misconfiguration?
            preconditionFailure("Requested to store stuff, but nothing found!")
        }

        guard let details = try await storageProvider.load(accountId, keys) else {
            // TODO: storage provider doesn't have a local copy, they will notify use with update details later on!
            return AccountDetails() // TODO: set a property or something?
        }

        return details
    }


    public func updateExternalStorage(with modifications: AccountModifications, for accountId: String) async throws {
        guard let storageProvider else {
            // TODO: any earlier point to tell them about misconfiguration?
            preconditionFailure("Requested to store stuff, but nothing found!")
        }

        try await storageProvider.modify(accountId, modifications)
    }

    @MainActor
    func willDeleteAccount(for accountId: String) async throws {
        try await storageProvider?.delete(accountId)

    }

    func userWillDisassociate(for accountId: String) async {
        await storageProvider?.disassociate(accountId)
    }

    // TODO: we can call disassociation ourselves! (we need to know before to preserve the account id!) => events? but then we cannot throw?
}


extension ExternalAccountStorage: Module, DefaultInitializable, Sendable {}


extension ExternalAccountStorage.ExternallyStoredDetails: Sendable, Hashable {}
