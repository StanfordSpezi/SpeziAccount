//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A stable identifier used by ``AccountStorageConstraint`` instances to identity a set of additionally stored records.
///
/// The identifier is built by combining a stable ``AccountService`` identifier and the primary accountID (see ``AccountIdKey``).
/// Using both, additional data records of a user can be uniquely identified across ``AccountService`` implementations.
public struct AdditionalRecordId: CustomStringConvertible, Hashable, Identifiable, Sendable {
    /// A stable ``AccountService`` identifier. See ``AccountService/id-83c6c``.
    public let accountServiceId: String // TODO: this should be removed!
    /// The primary user identifier. See ``AccountIdKey``.
    public let accountId: String


    /// String representation of the record identifier.
    public var description: String {
        accountServiceId + "-" + accountId
    }

    /// The identifier.
    public var id: String {
        description
    }


    init(serviceId accountServiceId: String, accountId: String) {
        self.accountServiceId = accountServiceId
        self.accountId = accountId
    }


    public static func == (lhs: AdditionalRecordId, rhs: AdditionalRecordId) -> Bool {
        lhs.description == rhs.description
    }


    public func hash(into hasher: inout Hasher) {
        accountServiceId.hash(into: &hasher)
        accountId.hash(into: &hasher)
    }
}
