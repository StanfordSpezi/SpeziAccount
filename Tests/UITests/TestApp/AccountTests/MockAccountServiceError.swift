//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum MockAccountServiceError: LocalizedError {
    case credentialsTaken
    case wrongCredentials
    
    
    var errorDescription: String? {
        switch self {
        case .credentialsTaken:
            return "User Identifier is already taken"
        case .wrongCredentials:
            return "Credentials do not match"
        }
    }
    
    var failureReason: String? {
        errorDescription
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .credentialsTaken:
            return "Please provide a different user identifier."
        case .wrongCredentials:
            return "Please ensure that the entered credentials are correct."
        }
    }
}
