//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import os
import SwiftUI


/// A model that is responsible to verify a list of ``ValidationRule``s.
///
/// You may use a `ValidationEngine` inside your view hierarchy (using [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject)
/// to manage the evaluation of your ``ValidationRule``s. The Engine provides easy access to bindings for current validity state of a the
/// processed input and a the respective recovery suggestions for failed ``ValidationRule``s.
/// The state of the `ValidationEngine` is updated on each invocation of ``runValidation(input:)`` or ``submit(input:debounce:)``.
public class ValidationEngine: ObservableObject, Identifiable {
    /// Determines the source of the last validation run.
    private enum Source {
        /// The last validation was run due to change in text field or keyboard submit.
        case submit
        /// The last validation was run due to manual interaction (e.g., a button press).
        case manual
    }


    /// The configuration of a ``ValidationEngine``.
    public struct Configuration: OptionSet, EnvironmentKey {
        /// This configuration controls the behavior of the ``ValidationEngine/displayedValidationResults`` property.
        ///
        /// If ``ValidationEngine/submit(input:debounce:)`` is called with empty input and this option is set, then the
        ///  ``ValidationEngine/displayedValidationResults`` will display no failed validations. However,
        ///  ``ValidationEngine/displayedValidationResults`` will still display all validations if validation is done through a manual call to ``ValidationEngine/runValidation(input:)``.
        public static let hideFailedValidationOnEmptySubmit = Configuration(rawValue: 1 << 0)

        /// Default value without any configuration options.
        public static let defaultValue: Configuration = []


        public let rawValue: UInt


        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }


    private static let logger = Logger(subsystem: "edu.stanford.spezi", category: "ValidationEngine")


    /// Unique identifier for this validation engine.
    public let id = UUID()

    /// Access to the underlying validation rules.
    public let validationRules: [ValidationRule]

    /// Access the configuration of the validation engine.
    public var configuration: Configuration

    /// A property that indicates if the last processed input is considered valid given the supplied ``ValidationRule`` list.
    ///
    /// The value treats no input at all (a validation that was never executed) as being invalid. Meaning, the default value is `false`.
    @MainActor @Published public var inputValid = false
    /// A list of ``FailedValidationResult`` for the processed input, providing, e.g., recovery suggestions.
    @MainActor @Published public var validationResults: [FailedValidationResult] = []

    /// Stores the source of the last validation execution. `nil` if validation was never run.
    private var source: Source?
    /// Input was empty. By default we consider no input as empty input.
    private var inputWasEmpty = true

    /// Flag that indicates if ``displayedValidationResults`` returns any ``FailedValidationResult``.
    @MainActor public var isDisplayingValidationErrors: Bool {
        if configuration.contains(.hideFailedValidationOnEmptySubmit) {
            return !inputValid && (source == .manual || !inputWasEmpty)
        }

        return !inputValid
    }


    /// A list of ``FailedValidationResult`` for the processed input that should be used by UI components.
    ///
    /// In certain scenarios it might the desirable to not display any validation results if the user erased the whole
    /// input field. You can achieve this by setting the ``ValidationEngine/Configuration-swift.struct/hideFailedValidationOnEmptySubmit`` option
    /// and using the ``submit(input:debounce:)`` method.
    ///
    /// - Note: When calling ``runValidation(input:)`` (e.g., on the button action) this field always delivers
    ///     the same results as the ``validationResults`` property.
    @MainActor public var displayedValidationResults: [FailedValidationResult] {
        isDisplayingValidationErrors ? validationResults : []
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
    ///   - configuration: The ``Configuration`` of the validation engine.
    public init(rules validationRules: [ValidationRule], debounceFor debounceDuration: Duration = .seconds(0.5), configuration: Configuration = []) {
        self.debounceDuration = debounceDuration
        self.validationRules = validationRules
        self.configuration = configuration
    }

    /// Initialize a new `ValidationEngine` by providing a list of ``ValidationRule``s.
    ///
    /// - Parameters:
    ///   - validationRules: A variadic array of validation rules.
    ///   - debounceDuration: The debounce duration used with ``submit(input:debounce:)`` and `debounce` set to `true`.
    ///   - configuration: The ``Configuration`` of the validation engine.
    public convenience init(
        rules validationRules: ValidationRule...,
        debounceFor debounceDuration: Duration = .seconds(0.5),
        configuration: Configuration = []
    ) {
        self.init(rules: validationRules, debounceFor: debounceDuration, configuration: configuration)
    }


    @MainActor
    private func computeFailedValidations(input: String) {
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

    @MainActor
    private func runValidation0(input: String, source: Source) {
        self.source = source // assign it first, as this isn't published
        self.inputWasEmpty = input.isEmpty

        computeFailedValidations(input: input)
        inputValid = validationResults.isEmpty
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
        guard debounce else {
            runValidation0(input: input, source: .submit)
            return
        }

        debounceTask = Task {
            try? await Task.sleep(for: debounceDuration)

            guard !Task.isCancelled else {
                return
            }

            runValidation0(input: input, source: .submit)
            self.debounceTask = nil
        }
    }

    /// Runs all validations for a given input.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed.
    /// - Parameter input: The input to validate.
    @MainActor
    public func runValidation(input: String) {
        runValidation0(input: input, source: .manual)
    }
}


extension EnvironmentValues {
    /// Access the ``ValidationEngine/Configuration-swift.struct`` from the environment.
    public var validationEngineConfiguration: ValidationEngine.Configuration {
        get {
            self[ValidationEngine.Configuration.self]
        }
        set {
            self[ValidationEngine.Configuration.self] = newValue
        }
    }
}
