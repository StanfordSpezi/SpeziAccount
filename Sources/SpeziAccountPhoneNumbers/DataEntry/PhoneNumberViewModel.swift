//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PhoneNumberKit
import SwiftUI

enum VerificationStep {
    case phoneNumber
    case verificationCode
}

@Observable
class PhoneNumberViewModel {
    var phoneNumber: PhoneNumber?
    var displayedPhoneNumber: String
    var selectedRegion: String
    var verificationCode: String
    var currentStep: VerificationStep
    var presentSheet: Bool
    var showDiscardAlert: Bool
    var phoneNumberUtility: PhoneNumberUtility
    
    init() {
        displayedPhoneNumber = ""
        selectedRegion = "US"
        verificationCode = ""
        currentStep = .phoneNumber
        presentSheet = false
        showDiscardAlert = false
        phoneNumberUtility = PhoneNumberUtility()
    }
    
    func resetState() {
        self.phoneNumber = nil
        self.displayedPhoneNumber = ""
        self.selectedRegion = "US"
        self.verificationCode = ""
        self.currentStep = .phoneNumber
        self.presentSheet = false
        self.showDiscardAlert = false
    }
    
    func countryFlag(for country: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        return country
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
    }
    
    func formatPhoneNumberForDisplay(_ phoneNumber: String) -> String {
        do {
            let number = try phoneNumberUtility.parse(phoneNumber)
            return phoneNumberUtility.format(number, toType: .national)
        } catch {
            return phoneNumber
        }
    }
}
