//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

public struct AdditionalRecordId: CustomStringConvertible, Hashable, Identifiable { // TODO move
    public let accountServiceId: String
    public let userId: String


    public var description: String {
        accountServiceId + "-" + userId
    }

    public var id: String {
        description
    }


    public init(serviceId accountServiceId: String, userId: String) {
        self.accountServiceId = accountServiceId
        self.userId = userId
    }


    public static func == (lhs: AdditionalRecordId, rhs: AdditionalRecordId) -> Bool {
        lhs.description == rhs.description
    }


    public func hash(into hasher: inout Hasher) {
        accountServiceId.hash(into: &hasher)
        userId.hash(into: &hasher)
    }
}


/// A `Spezi` Standard that manages data flow of additional account values.
///
/// Certain ``AccountService`` implementations might be limited to supported only a specific set of ``AccountValueKey``s
/// (see ``SupportedAccountKeys/exactly(ofKeys:)``. If you nonetheless want to use ``AccountValueKey``s that are unsupported
/// by your ``AccountService``, you may add an implementation of the `AccountStorageStandard` protocol to your App's `Standard`,
/// inorder to handle storage and retrieval of these additional account values.
public protocol AccountStorageStandard: Standard {
    /// Create new associated account data.
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
    ///   - keys: The keys to load. TODO how does the standard identify those (stable naming!!!)
    /// - Parameter userId: The userId to load data for.
    /// - Returns: The assembled ``PartialAccountDetails`` (see ``AccountValueStorageBuilder``).
    /// - Throws: A `LocalizedError`.
    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountValueKey.Type]) async throws -> PartialAccountDetails

    /// Modify the associated account data of an existing user account. TODO next load request must return updated data!
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
    func clear()

    /// Delete all associated account data.
    ///
    /// - Note: Due to the underlying architecture, there might still be a call to ``clear()`` after a call to
    ///     this method.
    /// - Parameter identifier: The primary identifier for stored record.
    /// - Throws: A `LocalizedError`.
    func delete(_ identifier: AdditionalRecordId) async throws
}
