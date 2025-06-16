//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PhoneNumberKit
import Spezi
import SwiftUI


public final class PhoneVerificationProvider: Module, EnvironmentAccessible, @unchecked Sendable {
    @StandardActor private var standard: any Standard
    
    private var phoneVerificationConstraint: any PhoneVerificationConstraint {
        guard let constraint = standard as? any PhoneVerificationConstraint else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
        return constraint
    }
    
    
    public init() { }
    
    @MainActor
    public func startVerification(phoneNumber: PhoneNumber) async throws {
        try await phoneVerificationConstraint.startVerification(phoneNumber)
    }
    
    @MainActor
    public func completeVerification(phoneNumber: PhoneNumber, code: String) async throws {
        try await phoneVerificationConstraint.completeVerification(phoneNumber, code)
    }
    
    @MainActor
    public func deletePhoneNumber(phoneNumber: PhoneNumber) async throws {
        try await phoneVerificationConstraint.delete(phoneNumber)
    }
}
