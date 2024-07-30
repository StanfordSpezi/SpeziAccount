//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Error while undergoing an account operation.
///
/// An error like that might occur due to restrictions or requirements imposed by ``AccountValueConfiguration``.
public enum AccountOperationError: LocalizedError {
    /// Missing account value.
    ///
    /// A ``AccountKeyRequirement/required`` ``AccountKey`` that was not supplied by the signup view before
    /// being passed to the ``AccountService``.
    ///
    /// - Note: This is an error in the view logic due to missing user-input sanitization or simply the view
    /// forgot to supply the ``AccountKey`` when building the ``AccountDetails``.
    case missingAccountValue(_ keyNames: [String])
    /// The stable user identifier was tired to be modified.
    ///
    /// The stable ``AccountDetails/accountId`` was tried to be modified.
    case accountIdChanged


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
            return "ACCOUNT_ERROR_VALUES_MISSING_VALUE_DESCRIPTION"
        case .accountIdChanged:
            return "ACCOUNT_ERROR_ACCOUNT_ID_CHANGED_DESCRIPTION"
        }
    }

    private var failureReasonValue: String.LocalizationValue {
        switch self {
        case let .missingAccountValue(keyName):
            return "ACCOUNT_ERROR_VALUES_MISSING_VALUE_REASON \(keyName.joined(separator: ", "))"
        case .accountIdChanged:
            return "ACCOUNT_ERROR_ACCOUNT_ID_CHANGED_REASON"
        }
    }

    private var recoverySuggestionValue: String.LocalizationValue {
        "ACCOUNT_ERROR_RECOVERY"
    }
}
