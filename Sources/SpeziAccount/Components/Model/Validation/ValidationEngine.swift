//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

public class ValidationEngine: ObservableObject {
    public let validationRules: [ValidationRule]

    @Published var inputValid = false
    @Published var validationResults: [LocalizedStringResource] = []

    public init(rules validationRules: [ValidationRule]) {
        self.validationRules = validationRules
    }

    public init(rules validationRules: ValidationRule...) {
        self.validationRules = validationRules
    }

    public func runValidationOnSubmit(input: String) {
        runValidation(input: input)
        inputValid = input.isEmpty || inputValid
    }

    public func runValidation(input: String) {
        // TODO do we want to run this on an async thread?
        validationResults = validationRules.compactMap { rule in
            rule.validate(input)
        }

        inputValid = validationResults.isEmpty
    }
}
