//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PhoneNumberKit
import SwiftUI

enum VerificationStep {
    case phoneNumber
    case verificationCode
}

@Observable class PhoneNumberViewModel {
    var phoneNumber: String
    var displayedPhoneNumber: String
    var selectedRegion: String
    var verificationCode: String
    var currentStep: VerificationStep
    var presentSheet: Bool
    var showDiscardAlert: Bool
    var phoneNumberUtility: PhoneNumberUtility
    
    init() {
        phoneNumber = ""
        displayedPhoneNumber = ""
        selectedRegion = "US"
        verificationCode = ""
        currentStep = .phoneNumber
        presentSheet = false
        showDiscardAlert = false
        phoneNumberUtility = PhoneNumberUtility()
    }
    
    func resetState() {
        self.phoneNumber = ""
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
}
