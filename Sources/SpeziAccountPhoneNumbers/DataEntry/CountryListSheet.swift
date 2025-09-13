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
    @Environment(PhoneNumberViewModel.self) private var phoneNumberViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchCountry = ""
    @State private var allCountries: [String] = []

    var filteredCountries: [String] {
        if searchCountry.isEmpty {
            return allCountries
        } else {
            return allCountries.filter { country in
                let countryCode = phoneNumberViewModel.phoneNumberUtility.countryCode(for: country)?.description ?? ""
                return country.lowercased().contains(searchCountry.lowercased())
                    || countryCode.contains(searchCountry)
                    || phoneNumberViewModel.localizedName(for: country).contains(searchCountry)
                    || phoneNumberViewModel.countryFlag(for: country).contains(searchCountry)
            }
        }
    }
    
    
    var body: some View {
        NavigationStack {
            List(filteredCountries, id: \.self) { country in
                HStack(spacing: 15) {
                    Text(phoneNumberViewModel.countryFlag(for: country))
                    Text(phoneNumberViewModel.localizedName(for: country))
                        .font(.headline)
                    Spacer()
                    Text("+" + (phoneNumberViewModel.phoneNumberUtility.countryCode(for: country)?.description ?? ""))
                        .foregroundColor(.secondary)
                }
                    .onTapGesture {
                        phoneNumberViewModel.selectedRegion = country
                        dismiss()
                    }
            }
                .listStyle(.inset)
                .presentationDetents([.medium, .large])
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Select Country Code")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if #available(iOS 26.0, macCatalyst 26.0, visionOS 26.0, macOS 26.0, watchOS 26.0, tvOS 26.0, *) {
                            Button(role: .cancel) {
                                dismiss()
                            }
                        } else {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                }
        }
        .task {
            var allCountries = phoneNumberViewModel.phoneNumberUtility.allCountries().filter { $0 != "001" }
            if let currentCountryIndex = allCountries.firstIndex(where: { $0 == Locale.current.region?.identifier ?? "" }) {
                allCountries.insert(allCountries.remove(at: currentCountryIndex), at: 0)
            }
            self.allCountries = allCountries
        }
        .onDisappear {
            searchCountry = ""
        }
        // Placement would be great to be on the toolbar level; unfortunately crashes in the current hierachy of sheets in the main usage.
        // Interestingly doesn't crash in the preview. Needs to be checked with new iOS releases.
        .searchable(text: $searchCountry, placement: .navigationBarDrawer, prompt: "Your country")
    }
}


#if DEBUG
#Preview {
    CountryListSheet()
        .environment(PhoneNumberViewModel())
}
#endif
