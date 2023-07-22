//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// Type erased way to encode the type of an ``AccountValueKey``.
public enum AccountValueType {
    /// The respective AccountValue MUST be provided by the user.
    /// See ``RequiredAccountValueKey``.
    case required
    /// The respective AccountValue CAN be provided by the user but there is no obligation to do so.
    /// See ``AccountValueKey``.
    case optional
}
