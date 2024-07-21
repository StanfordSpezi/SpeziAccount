//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Provides the type of initial value for an ``AccountKey``.
public enum InitialValue<Value> {
    /// The initial value is considered an empty value and the user is forced
    /// to provide their own input.
    ///
    /// This applies for example to most `String`-based values. `""` is an empty value that is considered
    /// to be no value at all. The user must provide some non-empty string.
    case empty(_ value: Value)
    /// The initial value is considered a default value and the user might change the selection
    /// or continue with the default provided.
    ///
    /// This often times applies to enum based values where there is a default case that already is valid selection.
    case `default`(_ value: Value)

    var value: Value {
        switch self {
        case let .empty(value):
            return value
        case let .default(value):
            return value
        }
    }
}

extension InitialValue: Equatable where Value: Equatable {}


extension InitialValue: Hashable where Value: Hashable {}


extension InitialValue: Sendable where Value: Sendable {}
