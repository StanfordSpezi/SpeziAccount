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
            fatalError("Failed to build lettersOnly rule")
        }

        // TODO validation rules are NOT localized!
        return ValidationRule(regex: regex, message: "You must only use letters!")
    }
}
