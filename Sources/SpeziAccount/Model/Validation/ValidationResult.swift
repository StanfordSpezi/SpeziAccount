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
    case failed
}
