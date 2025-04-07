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
    public func startVerification(data: [String: String]) async throws {
        if let phoneVerificationConstraint = standard as? any PhoneVerificationConstraint {
            try await phoneVerificationConstraint.startVerification(data)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
    
    @MainActor
    public func completeVerification(data: [String: String]) async throws {
        if let phoneVerificationConstraint = standard as? any PhoneVerificationConstraint {
            try await phoneVerificationConstraint.completeVerification(data)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `PhoneVerificationConstraint` to verify phone numbers.")
        }
    }
}
