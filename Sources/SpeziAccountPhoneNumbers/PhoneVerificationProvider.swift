//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


public class PhoneVerificationProvider: Module, EnvironmentAccessible {
    @StandardActor var standard: any Standard
    
    private var phoneVerificationConstraint: any PhoneVerificationConstraint {
        guard let constraint = standard as? any PhoneVerificationConstraint else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
        return constraint
    }
    
    
    public init() { }
    
    @MainActor
    public func startVerification(accountId: String, data: StartVerificationRequest) async throws {
        try await phoneVerificationConstraint.startVerification(accountId, data)
    }
    
    @MainActor
    public func completeVerification(accountId: String, data: CompleteVerificationRequest) async throws {
        try await phoneVerificationConstraint.completeVerification(accountId, data)
    }
    
    @MainActor
    public func deletePhoneNumber(accountId: String, number: String) async throws {
        try await phoneVerificationConstraint.delete(accountId, number)
    }
}
