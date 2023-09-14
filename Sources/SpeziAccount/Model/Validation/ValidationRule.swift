//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation


/// Controls how a ``ValidationEngine`` deals with subsequent validation rules if a given validation rule reports invalid input.
enum CascadingValidationEffect {
    /// The ``ValidationEngine`` continues to validate input against subsequent ``ValidationRule``s.
    case `continue`
    /// The ``ValidationEngine`` intercepts the current processing chain if the current rule reports invalid input and
    /// does not validate input against subsequent ``ValidationRule``s.
    case intercept
}


/// A rule used for validating text along with a message to display if the validation fails.
///
/// The following example demonstrates a ``ValidationRule`` using a regex expression for an email.
/// ```swift
/// ValidationRule(
///     regex: try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"),
///     message: "The entered email is not correct."
/// )
/// ```
///
/// - Important: Never rely on security-relevant validations with `ValidationRule`. These are client-side validations only!
///     Security-related validations MUST be checked at the server side (e.g., password length) and are just checked
///     on client-side for visualization.
public struct ValidationRule: Identifiable, @unchecked Sendable { // we guarantee that the closure is only executed on the main thread
    /// A unique identifier for the ``ValidationRule``. Can be used to, e.g., match a ``FailedValidationResult`` to the ValidationRule.
    public let id: UUID
    private let rule: (String) -> Bool
    /// A localized message that describes a recovery suggestion if the validation rule fails.
    public let message: LocalizedStringResource
    let effect: CascadingValidationEffect


    // swiftlint:disable:next function_default_parameter_at_end
    init(
        id: UUID = UUID(),
        ruleClosure: @escaping (String) -> Bool,
        message: LocalizedStringResource,
        effect: CascadingValidationEffect = .continue
    ) {
        self.id = id
        self.rule = ruleClosure
        self.message = message
        self.effect = effect
    }
    
    
    /// Creates a validation rule from an escaping closure.
    ///
    /// - Parameters:
    ///   - rule: An escaping closure that validates a `String` and returns a boolean result.
    ///   - message: A `String` message to display if validation fails.
    public init(rule: @escaping (String) -> Bool, message: LocalizedStringResource) {
        self.init(ruleClosure: rule, message: message)
    }

    /// Creates a validation rule from an escaping closure.
    ///
    /// - Parameters:
    ///   - rule: An escaping closure that validates a `String` and returns a boolean result.
    ///   - message: A `String` message to display if validation fails.
    ///   - bundle: The Bundle to localize for.
    public init(rule: @escaping (String) -> Bool, message: String.LocalizationValue, bundle: Bundle) {
        self.init(ruleClosure: rule, message: LocalizedStringResource(message, bundle: .atURL(from: bundle)))
    }
    
    /// Creates a validation rule from a regular expression.
    ///
    /// - Parameters:
    ///   - regex: A `Regex` regular expression to match for validating text. Note, the `wholeMatch` operation is used.
    ///   - message: A `LocalizedStringResource` message to display if validation fails.
    public init(regex: Regex<AnyRegexOutput>, message: LocalizedStringResource) {
        self.init(ruleClosure: { (try? regex.wholeMatch(in: $0) != nil) ?? false }, message: message)
    }

    /// Creates a validation rule from a regular expression.
    ///
    /// - Parameters:
    ///   - regex: A `Regex` regular expression to match for validating text. Note, the `wholeMatch` operation is used.
    ///   - message: A `String` message to display if validation fails.
    ///   - bundle: The Bundle to localize for.
    public init(regex: Regex<AnyRegexOutput>, message: String.LocalizationValue, bundle: Bundle) {
        self.init(regex: regex, message: LocalizedStringResource(message, bundle: .atURL(from: bundle)))
    }

    /// Creates a validation rule by copying the rule contents from another `ValidationRule`.
    /// - Parameters:
    ///   - validationRule: The `ValidationRule` to copy the rule from.
    ///   - message: A new message for the copied validation rule.
    public init(copy validationRule: ValidationRule, message: LocalizedStringResource) {
        self.init(ruleClosure: validationRule.rule, message: message)
    }

    
    /// Validates the contents of a given `String` input.
    /// - Parameter input: The input to validate.
    /// - Returns: Returns a ``FailedValidationResult`` if validation failed, otherwise `nil`.
    @MainActor
    public func validate(_ input: String) -> FailedValidationResult? {
        guard !rule(input) else {
            return nil
        }
        
        return FailedValidationResult(from: self)
    }
}


extension ValidationRule {
    /// Annotates an given ``ValidationRule`` such that a processing ``ValidationEngine`` intercepts the current
    /// processing chain of validation rules, if the current validation rule determines a given input to be invalid.
    /// - Parameter rule: The ``ValidationRule`` to modify.
    /// - Returns: Returns a modified ``ValidationRule``
    public var intercepting: ValidationRule {
        ValidationRule(id: id, ruleClosure: rule, message: message, effect: .intercept)
    }
}


extension ValidationRule: Decodable {
    enum CodingKeys: String, CodingKey {
        case rule
        case message
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let regexString = try values.decode(String.self, forKey: .rule)
        let regex = try Regex<AnyRegexOutput>(regexString)

        let message: LocalizedStringResource
        do {
            // backwards compatibility. An earlier version of `ValidationRule` used a non-localized string field.
            message = LocalizedStringResource(stringLiteral: try values.decode(String.self, forKey: .message))
        } catch {
            message = try values.decode(LocalizedStringResource.self, forKey: .message)
        }

        self.init(regex: regex, message: message)
    }
}
