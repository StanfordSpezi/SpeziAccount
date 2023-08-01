//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation


extension ValidationRule {
    /// A `ValidationRule` that checks that the supplied content is non-empty (`\S+`).
    ///
    /// The definition of **non-empty** in this context refers to: a string that is not the empty string and
    /// does also not just contain whitespace-only characters.
    public static var nonEmpty: ValidationRule = {
        guard let regex = try? Regex(#"\S+"#) else {
            fatalError("Failed to build the nonEmpty validation rule!")
        }

        return ValidationRule(regex: regex, message: "VALIDATION_RULE_NON_EMPTY", bundle: .module)
    }()

    /// A `ValidationRule` that checks that the supplied content only contains unicode letters.
    ///
    /// - See: `Character/isLetter`.
    public static var unicodeLettersOnly: ValidationRule = {
        ValidationRule(rule: { $0.allSatisfy { $0.isLetter } }, message: "VALIDATION_RULE_UNICODE_LETTERS", bundle: .module)
    }()

    /// A `ValidationRule` that checks that the supplied contain only contains ASCII letters.
    ///
    /// - Note: It is recommended to use ``unicodeLettersOnly`` in production environments.
    /// - See: `Character/isASCII`.
    public static var asciiLettersOnly: ValidationRule = {
        ValidationRule(rule: { $0.allSatisfy { $0.isASCII } }, message: "VALIDATION_RULE_UNICODE_LETTERS_ASCII", bundle: .module)
    }()

    /// A `ValidationRule` that imposes minimal constraints on a E-Mail input.
    ///
    /// This ValidationRule matches with any strings that contain at least one `@` symbol followed by at least one
    /// character (`.*@.+`). Use this in environments where you verify the existence and ownership of the E-Mail
    /// address (e.g., by sending a verification link to the address).
    ///
    /// - See: A more detailed discussion about validation E-Mail inout can be found [here](https://stackoverflow.com/a/48170419).
    public static var minimalEmail: ValidationRule = {
        guard let regex = try? Regex(".*@.+") else {
            fatalError("Failed to build the minimalEmail validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_MINIMAL_EMAIL",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 8 characters for minimal password complexity.
    ///
    /// An application must make sure that users choose sufficiently secure passwords while at the same time ensuring that
    /// usability is not affected due to too complex restrictions. This basic motivation stems from `ORP.4.A22 Regulating Password Quality`
    /// of the [IT-Grundschutz Compendium](https://www.bsi.bund.de/EN/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/IT-Grundschutz/it-grundschutz_node.html)
    /// of the German Federal Office for Information Security.
    /// We propose to use the password length as the sole factor to determine password complexity. We rely on the
    /// recommendations of NIST who discuss the [Strength of Memorized Secrets](https://pages.nist.gov/800-63-3/sp800-63b.html#appA)
    /// great detail and recommend against password rules that mandated a certain mix of character types.
    public static var minimalPassword: ValidationRule = { // TODO is above a prominent location for such a discussion?
        guard let regex = try? Regex(#".{8,}"#) else {
            fatalError("Failed to build the minimalPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_MINIMAL_PASSWORD",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 10 characters for improved password complexity.
    ///
    /// See ``minimalPassword`` for a discussion and recommendation on password complexity rules.
    public static var mediumPassword: ValidationRule = {
        guard let regex = try? Regex(#".{10,}"#) else {
            fatalError("Failed to build the mediumPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_MEDIUM_PASSWORD",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 10 characters for extended password complexity.
    ///
    /// See ``minimalPassword`` for a discussion and recommendation on password complexity rules.
    public static var strongPassword: ValidationRule = {
        guard let regex = try? Regex(#".{12,}"#) else {
            fatalError("Failed to build the strongPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_STRONG_PASSWORD",
            bundle: .module
        )
    }()
}
