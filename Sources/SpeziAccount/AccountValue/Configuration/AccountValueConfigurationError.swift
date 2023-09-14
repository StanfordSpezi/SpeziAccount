//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// An error that occurs due to restrictions or requirements of a ``AccountValueConfiguration``.
public enum AccountValueConfigurationError: LocalizedError {
    /// A ``AccountKeyRequirement/required`` ``AccountKey`` that was not supplied by the signup view before
    /// being passed to the ``AccountService``.
    ///
    /// - Note: This is an error in the view logic due to missing user-input sanitization or simply the view
    /// forgot to supply the ``AccountKey`` when building the ``SignupDetails``.
    case missingAccountValue(_ keyNames: [String])


    public var errorDescription: String? {
        .init(localized: errorDescriptionValue, bundle: .module)
    }

    public var failureReason: String? {
        .init(localized: failureReasonValue, bundle: .module)
    }

    public var recoverySuggestion: String? {
        .init(localized: recoverySuggestionValue, bundle: .module)
    }


    private var errorDescriptionValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue:
            return "ACCOUNT_VALUES_MISSING_VALUE_DESCRIPTION"
        }
    }

    private var failureReasonValue: String.LocalizationValue {
        switch self {
        case let .missingAccountValue(keyName):
            return "ACCOUNT_VALUES_MISSING_VALUE_REASON \(keyName.joined(separator: ", "))"
        }
    }

    private var recoverySuggestionValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue:
            return "ACCOUNT_VALUES_MISSING_VALUE_RECOVERY"
        }
    }
}
