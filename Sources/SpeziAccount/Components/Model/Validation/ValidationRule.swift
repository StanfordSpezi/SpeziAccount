//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A rule used for validating text along with a message to display if the validation fails.
///
/// The following example demonstrates a ``ValidationRule`` using a regex expression for an email.
/// ```swift
/// ValidationRule(
///     regex: try? Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"),
///     message: "The entered email is not correct."
/// )
/// ```
public struct ValidationRule: Decodable {
    enum CodingKeys: String, CodingKey {
        case rule
        case message
    }
    
    
    private let rule: (String) -> Bool
    private let message: LocalizedStringResource
    
    
    /// Creates a validation rule from an escaping closure
    ///
    /// - Parameters:
    ///   - rule: An escaping closure that validates a `String` and returns a boolean result
    ///   - message: A `String` message to display if validation fails
    public init(rule: @escaping (String) -> Bool, message: LocalizedStringResource) {
        self.rule = rule
        self.message = message
    }
    
    /// Creates a validation rule from a regular expression
    ///
    /// - Parameters:
    ///   - regex: A `Regex` regular expression to match for validating text
    ///   - message: A `LocalizedStringResource` message to display if validation fails
    public init(regex: Regex<AnyRegexOutput>, message: LocalizedStringResource) {
        self.rule = { input in
            (try? regex.wholeMatch(in: input) != nil) ?? false
        }
        self.message = message
    }

    /// Creates a validation rule from a regular expression
    ///
    /// - Parameters:
    ///   - regex: A `Regex` regular expression to match for validating text
    ///   - message: A `String` message to display if validation fails
    ///   - bundle: The Bundle to localize for.
    public init(regex: Regex<AnyRegexOutput>, message: String, bundle: Bundle) {
        self.init(regex: regex, message: message.localized(bundle))
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let regexString = try values.decode(String.self, forKey: .rule)
        let regex = try Regex<AnyRegexOutput>(regexString)

        let message: LocalizedStringResource
        do {
            message = LocalizedStringResource(stringLiteral: try values.decode(String.self, forKey: .message))
        } catch {
            message = try values.decode(LocalizedStringResource.self, forKey: .message)
        }

        self.init(regex: regex, message: message)
    }
    
    /// Validates the contents of a `String` and returns a `String` error message if validation fails
    func validate(_ input: String) -> LocalizedStringResource? {
        guard !rule(input) else {
            return nil
        }
        
        return message
    }
}
