//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation


extension ValidationRule {
    static let acceptAll: ValidationRule = { // TODO: is that used?
        ValidationRule(rule: { _ in true }, message: "VALIDATION_RULE_ALWAYS_ACCEPT", bundle: .module)
    }()
}
