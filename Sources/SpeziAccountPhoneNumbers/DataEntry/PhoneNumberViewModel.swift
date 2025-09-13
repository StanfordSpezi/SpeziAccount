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
        selectedRegion = Locale.current.region?.identifier ?? "US"
        verificationCode = ""
        currentStep = .phoneNumber
        presentSheet = false
        showDiscardAlert = false
        phoneNumberUtility = PhoneNumberUtility()
    }
    
    func resetState() {
        self.phoneNumber = nil
        self.displayedPhoneNumber = ""
        self.selectedRegion = Locale.current.region?.identifier ?? "US"
        self.verificationCode = ""
        self.currentStep = .phoneNumber
        self.presentSheet = false
        self.showDiscardAlert = false
    }
    
    func countryFlag(for country: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        let countryFlag = country
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
        guard countryFlag != "🇕🇕🇖" else {
            return "🏳️"
        }
        
        return countryFlag
    }
    
    func localizedName(for country: String) -> String {
        if let countryName = Locale.current.localizedString(forRegionCode: country), countryName != "world" {
            countryName
        } else {
            country
        }
    }
    
    func formatPhoneNumberForDisplay(_ phoneNumber: PhoneNumber) -> String {
        "+\(phoneNumber.countryCode) " + phoneNumberUtility.format(phoneNumber, toType: .national)
    }
}
