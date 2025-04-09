//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A `Spezi` Standard that provides phone number verification functionality.
///
/// Adopt this protocol in your Standard to implement phone number verification services.
/// This protocol defines the interface for starting and completing phone verification processes.
///
/// - Note: The `data` parameter in both methods typically contains:
///   - For `startVerification`: The phone number to verify
///   - For `completeVerification`: The verification code to validate
public protocol PhoneVerificationConstraint: Standard {
    /// Starts the phone verification process.
    /// - Parameter data: Dictionary containing verification data, typically including the phone number.
    /// - Throws: An error if the verification process cannot be started.
    func startVerification(_ data: [String: String]) async throws -> Void
    
    /// Completes the phone verification process.
    /// - Parameter data: Dictionary containing verification data, typically including the verification code.
    /// - Throws: An error if the verification process cannot be completed.
    func completeVerification(_ data: [String: String]) async throws -> Void
    
    /// Deletes the phone number.
    /// - Parameter number: The phone number.
    /// - Throws: An error if the deletion cannot be completed.
    func delete(_ number: String) async throws -> Void
}
