//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
// TODO shall we move this infrastructure (+ some modifieris) to SpeziViews?


/// A model that is responsible to verify a list of ``ValidationRule``s.
///
/// You may use a `ValidationEngine` inside your view hierarchy (using `@StateObject`) to manage the evaluation
/// of your ``ValidationRule``s. The Engine provides easy access to bindings for current validity state of a the
/// processed input and a the respective recovery suggestions for failed ``ValidationRule``s.
/// The state of the `ValidationEngine` is updated on each invocation of ``runValidation(input:)`` or ``runValidationOnSubmit(input:)``.
public class ValidationEngine: ObservableObject {
    /// Access to the underlying validation rules
    public var validationRules: [ValidationRule]

    /// A property that indicates if the last processed input is considered valid given the supplied ``ValidationRule`` list.
    @Published public var inputValid = false
    /// A list of ``FailedValidationResult`` for the processed input for failed validations, providing, e.g., recovery suggestions.
    /// - Note: Even if ``inputValid`` reports `true`, this array may be non-empty. For more information see ``runValidationOnSubmit(input:)``.
    @Published public var validationResults: [FailedValidationResult] = []

    public init(rules validationRules: [ValidationRule]) {
        self.validationRules = validationRules
    }

    public init(rules validationRules: ValidationRule...) {
        self.validationRules = validationRules
    }

    private func runValidation0(input: String) {
        // TODO do we want to run this on an async thread?

        var results: [FailedValidationResult] = []
        for rule in validationRules {
            if let failedValidation = rule.validate(input) {
                results.append(failedValidation)

                if rule.effect == .intercept {
                    break
                }
            }
        }
        validationResults = results
    }

    /// Runs all validations for a given input on text field submission.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed or the input is empty. This is particularly
    /// useful to reset go back to a valid state if the user submits a empty string in the text field.
    /// Make sure to run ``runValidation(input:)`` one last time to process the data (e.g., on a button action).
    /// - Parameter input: The input to validate.
    public func runValidationOnSubmit(input: String) {
        runValidation0(input: input)
        inputValid = input.isEmpty || inputValid
    }

    /// Runs all validations for a given input.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed.
    /// - Parameter input: The input to validate.
    public func runValidation(input: String) {
        runValidation0(input: input)
        inputValid = validationResults.isEmpty
    }
}
