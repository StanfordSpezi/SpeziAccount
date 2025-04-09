//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PhoneNumberKit
import SwiftUI

public enum VerificationStep {
    case phoneNumber
    case verificationCode
}

@Observable public class PhoneNumberViewModel {
    public var phoneNumber: String
    public var displayedPhoneNumber: String
    public var selectedRegion: String
    public var verificationCode: String
    public var currentStep: VerificationStep
    public var presentSheet: Bool
    public var showDiscardAlert: Bool
    public var phoneNumberUtility: PhoneNumberUtility
    var accountDetailsBuilder: AccountDetailsBuilder?
    
    public init() {
        phoneNumber = ""
        displayedPhoneNumber = ""
        selectedRegion = "US"
        verificationCode = ""
        currentStep = .phoneNumber
        presentSheet = false
        showDiscardAlert = false
        phoneNumberUtility = PhoneNumberUtility()
    }
    
    public func resetState() {
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
