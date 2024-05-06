//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Provides the type of initial value for an ``AccountKey``.
public struct InitialValue<Value> {
    /// The semantics and behavior of a initial value.
    public enum Semantics {
        /// The initial value is considered an empty value and the user is forced
        /// to provide their own input.
        ///
        /// This applies for example to most `String`-based values. `""` is an empty value that is considered
        /// to be no value at all. The user must provide some non-empty string.
        case emptyValue
        /// The initial value is considered a default value and the user might change the selection
        /// or continue with the default provided.
        ///
        /// This often times applies to enum-based values where there is a default case that already represents valid selection.
        case defaultValue
    }

    /// The initial value.
    public let value: Value
    /// Specifies the behavior of the initial value.
    public let semantics: Semantics


    fileprivate init(semantics: Semantics, value: Value) {
        self.semantics = semantics
        self.value = value
    }
}


extension InitialValue {
    /// The initial value is considered an empty value and the user is forced
    /// to provide their own input.
    ///
    /// This applies for example to most `String`-based values. `""` is an empty value that is considered
    /// to be no value at all. The user must provide some non-empty string.
    /// - Parameter value: The value.
    /// - Returns: A initial value with ``Semantics-swift.enum/emptyValue`` semantics.
    public static func empty(_ value: Value) -> InitialValue {
        InitialValue(semantics: .emptyValue, value: value)
    }

    /// The initial value is considered a default value and the user might change the selection
    /// or continue with the default provided.
    ///
    /// This often times applies to enum based values where there is a default case that already represents valid selection.
    /// - Parameter value: The value.
    /// - Returns: A initial value with ``Semantics-swift.enum/defaultValue`` semantics.
    public static func `default`(_ value: Value) -> InitialValue {
        InitialValue(semantics: .defaultValue, value: value)
    }
}


extension InitialValue.Semantics: Hashable, Sendable {}


extension InitialValue: Equatable where Value: Equatable {}


extension InitialValue: Hashable where Value: Hashable {}


extension InitialValue: Sendable where Value: Sendable {}
