//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// A collection of feature flags for the Test App.
enum FeatureFlags {
    /// Configures the SpeziAccount AccountServices to be empty!
    static let emptyAccountServices = CommandLine.arguments.contains("--emptyAccountServices")
}
