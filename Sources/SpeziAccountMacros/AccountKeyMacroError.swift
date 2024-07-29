//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


enum AccountKeyMacroError: Error, CustomStringConvertible {
    case couldNotDetermineIdentifier
    case argumentListInconsistency
    case propertyIsMissingTypeAnnotation
    case unableToDetermineValueArgument
    case failedKeyPathParsing
    case typesNotMatching(argument: String, variable: String)

    var description: String {
        switch self {
        case .couldNotDetermineIdentifier:
            "@AccountKey macro was unable to determine the property name."
        case .argumentListInconsistency:
            "Missing or unexpected list of arguments passed to macro."
        case .propertyIsMissingTypeAnnotation:
            "@AccountKey macro property is missing the type annotation."
        case .unableToDetermineValueArgument:
            "@AccountKey macro failed to parse the `as:` type argument."
        case .failedKeyPathParsing:
            "@KeyEntry macro failed to parse KeyPath expression."
        case let .typesNotMatching(argument, variable):
            "Argument type '\(argument)' did not match expected variable type '\(variable)'"
        }
    }
}
