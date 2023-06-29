//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension ValidationRule {
    /// Default ValidationRule that requires only letters: `[a-zA-Z]*`.
    public static var lettersOnly: ValidationRule {
        guard let regex = try? Regex("[a-zA-Z]*") else {
            fatalError("Failed to build lettersOnly rule!")
        }

        // TODO validation rules are NOT localized!
        return ValidationRule(regex: regex, message: "You must only use letters!")
    }

    public static var nonEmpty: ValidationRule {
        guard let regex = try? Regex("(.)+") else {
            fatalError("Failed to build nonEmpty rule!")
        }

        return ValidationRule(regex: regex, message: "Cannot be empty!")
    }

    public static var emailValidationRule: ValidationRule {
        guard let regex = try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") else {
            fatalError("Invalid E-Mail Regex in the EmailPasswordAccountService")
        }

        return ValidationRule(
            regex: regex,
            message: "EAP_EMAIL_VERIFICATION_ERROR",
            bundle: .module
        )
    }
}
