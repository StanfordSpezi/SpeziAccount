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
    
    
    public init() { }


    public func configure() {
        guard standard is any PhoneVerificationConstraint else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
    
    @MainActor
    public func startVerification(accountId: String, data: [String: String]) async throws {
        if let phoneVerificationConstraint = standard as? any PhoneVerificationConstraint {
            try await phoneVerificationConstraint.startVerification(accountId, data)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
    
    @MainActor
    public func completeVerification(accountId: String, data: [String: String]) async throws {
        if let phoneVerificationConstraint = standard as? any PhoneVerificationConstraint {
            try await phoneVerificationConstraint.completeVerification(accountId, data)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
    
    @MainActor
    public func deletePhoneNumber(accountId: String, number: String) async throws {
        if let phoneVerificationConstraint = standard as? any PhoneVerificationConstraint {
            try await phoneVerificationConstraint.delete(accountId, number)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
}
