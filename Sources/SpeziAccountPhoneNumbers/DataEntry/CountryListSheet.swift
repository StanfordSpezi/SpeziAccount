//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PhoneNumberKit
import SwiftUI


struct CountryListSheet: View {
    @Environment(PhoneNumberViewModel.self)
    private var phoneNumberViewModel
    @Environment(\.dismiss)
    private var dismiss
    @State private var searchCountry = ""
    @State private var allCountries: [String] = []

    var filteredCountries: [String] {
        if searchCountry.isEmpty {
            return allCountries
        } else {
            return allCountries.filter { country in
                let countryCode = phoneNumberViewModel.phoneNumberUtility.countryCode(for: country)?.description ?? ""
                return country.lowercased().contains(searchCountry.lowercased()) ||
                countryCode.contains(searchCountry)
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            List(filteredCountries, id: \.self) { country in
                HStack(spacing: 15) {
                    Text(phoneNumberViewModel.countryFlag(for: country))
                    Text(country)
                        .font(.headline)
                    Spacer()
                    Text("+" + (phoneNumberViewModel.phoneNumberUtility.countryCode(for: country)?.description ?? ""))
                        .foregroundColor(.secondary)
                }
                    .onTapGesture {
                        phoneNumberViewModel.selectedRegion = country
                        dismiss()
                        searchCountry = ""
                    }
            }
                .listStyle(.plain)
                .searchable(text: $searchCountry, prompt: "Your country")
        }
            .padding(.top, 5)
            .presentationDetents([.medium, .large])
            .task {
                allCountries = phoneNumberViewModel.phoneNumberUtility.allCountries()
            }
            .onDisappear {
                searchCountry = ""
            }
    }
}


#if DEBUG
#Preview {
    CountryListSheet()
}
#endif
