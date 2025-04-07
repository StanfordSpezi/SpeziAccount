//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PhoneNumberKit
import SpeziValidation
import SwiftUI


struct PhoneNumberEntryField: View {
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @State private var presentSheet = false
    let phoneNumberUtility: PhoneNumberUtility
    
    var body: some View {
        HStack(spacing: 15) {
            countryPickerButton
            phoneNumberEntryField
        }
            .padding(6)
            .background(Color(uiColor: .secondarySystemBackground))
            .mask(RoundedRectangle(cornerRadius: 8))
            .sheet(isPresented: $presentSheet) {
                CountryListSheet(phoneNumberUtility: phoneNumberUtility)
            }
    }
    
    
    var countryPickerButton: some View {
        Button {
            presentSheet = true
        } label: {
            Text(
                phoneNumberViewModel.countryFlag(for: phoneNumberViewModel.selectedRegion) +
                " " +
                "+\(phoneNumberUtility.countryCode(for: phoneNumberViewModel.selectedRegion)?.description ?? "")"
            )
                .foregroundColor(.secondary)
                .padding([.leading, .trailing], 15)
                .padding([.top, .bottom], 7)
                .frame(minWidth: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: .tertiarySystemFill))
                )
        }
    }
    
    var phoneNumberEntryField: some View {
        let textBinding = Binding<String>(
            get: { phoneNumberViewModel.displayedPhoneNumber },
            set: { newValue in
                phoneNumberViewModel.displayedPhoneNumber = newValue
            }
        )
        
        return VerifiableTextField(
            "Phone Number",
            text: textBinding
        )
            .validate(input: phoneNumberViewModel.displayedPhoneNumber, rules: [
                ValidationRule(
                    rule: {[phoneNumberUtility = phoneNumberUtility, region = phoneNumberViewModel.selectedRegion] phoneNumber in
                        phoneNumberUtility.isValidPhoneNumber(phoneNumber, withRegion: region) || phoneNumber.isEmpty
                    },
                    message: "The entered phone number is invalid."
                )
            ])
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)
            .onChange(of: phoneNumberViewModel.displayedPhoneNumber) { _, newValue in
                do {
                    let number = try phoneNumberUtility.parse(newValue, withRegion: phoneNumberViewModel.selectedRegion)
                    phoneNumberViewModel.displayedPhoneNumber = phoneNumberUtility.format(number, toType: .national)
                    phoneNumberViewModel.phoneNumber = phoneNumberUtility.format(number, toType: .e164)
                } catch {
                    phoneNumberViewModel.phoneNumber = ""
                }
            }
            .id(phoneNumberViewModel.selectedRegion) // to trigger a update of the validation rule upon changes of selectedRegion
    }
}


#if DEBUG
#Preview {
    PhoneNumberEntryField(phoneNumberUtility: PhoneNumberUtility())
}
#endif
