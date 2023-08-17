//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The result of a data validation task
public enum ValidationResult {
    /// Data was validated successfully. No malformed input found.
    case success
    /// The input data was not valid.
    ///
    /// This indicates that the current value can't be considered valid and must not be used or saved.
    ///
    /// If this is the first field for which validation failed, focus will automatically move the respective field.
    /// - Note: If you have a ``AccountValueKey`` that is composed of multiple fields, you may use
    ///     ``failedAtField(focusedField:)`` to specify which field should receive focus.
    case failed
    /*
     TODO docs
    /// The input data was not valid for a specified field.
    ///
    /// This indicates that the current value can't be considered valid and must not be used or saved.
    ///
    /// If this is the first field for which validation failed, focus will automatically move the
    /// specified field.
    case failedAtField(focusedField: FieldIdentifier) // TODO remove?
    */
}

public enum FieldValidationResult<FieldIdentifier> {
    case success
    case failedAtField(fieldIdentifier: FieldIdentifier)
}
