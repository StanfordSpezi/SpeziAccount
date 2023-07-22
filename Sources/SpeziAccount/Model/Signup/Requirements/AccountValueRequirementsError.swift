//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// An error that occurs during building or verification of ``AccountValueKey``.
public enum AccountValueRequirementsError: LocalizedError {
    /// An non-optional ``AccountValueKey`` that was configured but not supplied by the signup view before
    /// being passed to the ``AccountService``.
    ///
    /// - Note: This is an error in the view logic due to missing user-input sanitization or simply the view
    /// didn't supply the ``AccountValueKey`` when building the ``SignupRequest``.
    case missingAccountValue(_ keyName: String)

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
        case .missingAccountValue: // TODO replace value?
            return "ACCOUNT_VALUES_MISSING_VALUE_DESCRIPTION"
        }
    }

    private var failureReasonValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue: // TODO replace value?
            return "ACCOUNT_VALUES_MISSING_VALUE_REASON"
        }
    }

    private var recoverySuggestionValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue: // TODO replace value?
            return "ACCOUNT_VALUES_MISSING_VALUE_RECOVERY"
        }
    }
}