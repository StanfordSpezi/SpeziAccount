//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A stable identifier used by ``AccountStorageStandard`` instances to identity a set of additionally stored records.
///
/// The identifier is built by combining a stable ``AccountService`` identifier and the primary userId (see ``UserIdKey``).
/// Using both, additional data records of a user can be uniquely identified across ``AccountService`` implementations.
public struct AdditionalRecordId: CustomStringConvertible, Hashable, Identifiable {
    /// A stable ``AccountService`` identifier. See ``AccountService/id-83c6c``.
    public let accountServiceId: String
    /// The primary user identifier. See ``UserIdKey``.
    public let userId: String


    /// String representation of the record identifier.
    public var description: String {
        accountServiceId + "-" + userId
    }

    /// The identifier.
    public var id: String {
        description
    }


    init(serviceId accountServiceId: String, userId: String) {
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
