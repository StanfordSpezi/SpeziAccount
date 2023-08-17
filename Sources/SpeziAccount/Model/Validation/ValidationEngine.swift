//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import os
// TODO shall we move this infrastructure to SpeziViews?


/// A model that is responsible to verify a list of ``ValidationRule``s.
///
/// You may use a `ValidationEngine` inside your view hierarchy (using `@StateObject`) to manage the evaluation
/// of your ``ValidationRule``s. The Engine provides easy access to bindings for current validity state of a the
/// processed input and a the respective recovery suggestions for failed ``ValidationRule``s.
/// The state of the `ValidationEngine` is updated on each invocation of ``runValidation(input:)`` or ``submit(input:debounce:)``.
public class ValidationEngine: ObservableObject, Identifiable {
    private static let logger = Logger(subsystem: "edu.stanford.spezi", category: "ValidationEngine")
    
    /// Unique identifier for this validation engine.
    public let id = UUID()

    /// Access to the underlying validation rules
    public let validationRules: [ValidationRule]

    /// A property that indicates if the last processed input is considered valid given the supplied ``ValidationRule`` list.
    @MainActor @Published public var inputValid = false
    /// A list of ``FailedValidationResult`` for the processed input, providing, e.g., recovery suggestions.
    /// - Note: Even if ``inputValid`` reports `true`, this array may be non-empty. For more information see ``submit(input:debounce:)``
    ///     and ``displayedValidationResults``.
    @MainActor @Published public var validationResults: [FailedValidationResult] = []

    /// A list of ``FailedValidationResult`` for the processed input that doesn't display anything if ``inputValid`` is `true`.
    ///
    /// In certain scenarios it might the desirable to not display any validation results if the user erased the whole
    /// input field. You can achieve this by only displaying ``FieldValidationResult`` provided by this property and
    /// calling ``submit(input:debounce:)`` for any input changes.
    ///
    /// - Note: When calling ``runValidation(input:)`` (e.g., on the final submit button action) this field delivers
    ///     the same results as the ``validationResults`` property.
    @MainActor public var displayedValidationResults: [FailedValidationResult] {
        inputValid ? [] : validationResults
    }

    private let debounceDuration: Duration
    private var debounceTask: Task<Void, Never>? {
        willSet {
            debounceTask?.cancel()
        }
    }

    /// Initialize a new `ValidationEngine` by providing a list of ``ValidationRule``s.
    ///
    /// - Parameters:
    ///   - validationRules: An array of validation rules.
    ///   - debounceDuration: The debounce duration used with ``submit(input:debounce:)`` and `debounce` set to `true`.
    public init(rules validationRules: [ValidationRule], debounceFor debounceDuration: Duration = .seconds(0.5)) {
        self.debounceDuration = debounceDuration
        self.validationRules = validationRules
    }

    /// Initialize a new `ValidationEngine` by providing a list of ``ValidationRule``s.
    ///
    /// - Parameters:
    ///   - validationRules: A variadic array of validation rules.
    ///   - debounceDuration: The debounce duration used with ``submit(input:debounce:)`` and `debounce` set to `true`.
    public convenience init(rules validationRules: ValidationRule..., debounceFor debounceDuration: Duration = .seconds(0.5)) {
        self.init(rules: validationRules, debounceFor: debounceDuration)
    }

    @MainActor
    private func runValidation0(input: String) {
        var results: [FailedValidationResult] = []
        for rule in validationRules {
            if let failedValidation = rule.validate(input) {
                results.append(failedValidation)
                Self.logger.debug("Validation for input '\(input.description)' failed with reason: \(failedValidation.localizedStringResource.localizedString())")

                if rule.effect == .intercept {
                    break
                }
            }
        }
        validationResults = results
    }

    /// Runs all validations for a given input on text field submission or value change.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed or the input is empty. This is particularly
    /// useful to reset go back to a valid state if the user submits a empty string in the text field.
    /// Make sure to run ``runValidation(input:)`` one last time to process the data (e.g., on a button action).
    ///
    /// - Parameters:
    ///   - input: The input to validate.
    ///   - debounce: If set to `true` calls to this method will be "debounced". The validation will not run as long as
    ///     there not further calls to this method for the configured `debounceDuration`. If set to `false` the method
    ///     will run immediately.
    @MainActor
    public func submit(input: String, debounce: Bool = false) {
        let validation = {
            self.runValidation0(input: input)
            self.inputValid = input.isEmpty || self.validationResults.isEmpty
        }

        guard debounce else {
            validation()
            return
        }

        debounceTask = Task {
            try? await Task.sleep(for: debounceDuration)

            guard !Task.isCancelled else {
                return
            }

            validation()

            self.debounceTask = nil
        }
    }

    /// Runs all validations for a given input.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed.
    /// - Parameter input: The input to validate.
    @MainActor
    public func runValidation(input: String) {
        runValidation0(input: input)
        inputValid = validationResults.isEmpty
    }
}
