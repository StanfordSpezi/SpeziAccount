//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Describes the requirement level for an ``AccountKey``.
public enum AccountKeyRequirement: Sendable {
    /// The associated account value **must** be provided by the user at signup.
    ///
    /// It is mandatory to use the ``RequiredAccountKey`` protocol.
    case required
    /// The associated account value **can** be provided by the user at signup.
    ///
    /// The account value is collected at signup but there is no obligation for the user
    /// to provide a value.
    case collected
    /// The associated account value **can** be provided by the user at a later point in time.
    ///
    /// The account value is **not** collected at signup. However, it is displayed in the account overview
    /// and a user can supply a value by editing their account details.
    case supported
}
