//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum AccountValueRequirementsError: LocalizedError {
    case missingAccountValue

    var errorDescription: String? {
        .init(localized: errorDescriptionValue, bundle: .module)
    }

    var recoverySuggestion: String? {
        .init(localized: recoverySuggestionValue, bundle: .module)
    }

    private var errorDescriptionValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue:
            return "" // TODO localization
        }
    }

    private var recoverySuggestionValue: String.LocalizationValue {
        switch self {
        case .missingAccountValue:
            return "" // TODO localization
        }
    }
}