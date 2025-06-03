//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PhoneNumberKit
import Spezi


/// The request for starting phone verification.
public struct StartVerificationRequest: Sendable, Equatable, Codable {
    public let phoneNumber: PhoneNumber

    public init(phoneNumber: PhoneNumber) {
        self.phoneNumber = phoneNumber
    }
}

/// The request for completing phone verification.
public struct CompleteVerificationRequest: Sendable, Equatable, Codable {
    public let phoneNumber: PhoneNumber
    public let code: String

    public init(phoneNumber: PhoneNumber, code: String) {
        self.phoneNumber = phoneNumber
        self.code = code
    }
}

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
    func startVerification(_ accountId: String, _ data: StartVerificationRequest) async throws
    
    /// Completes the phone verification process.
    /// - Parameter data: Dictionary containing verification data, typically including the verification code.
    /// - Throws: An error if the verification process cannot be completed.
    func completeVerification(_ accountId: String, _ data: CompleteVerificationRequest) async throws
    
    /// Deletes the phone number.
    /// - Parameter number: The phone number.
    /// - Throws: An error if the deletion cannot be completed.
    func delete(_ accountId: String, _ number: PhoneNumber) async throws
}
