//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SpeziValidation
import SwiftUI


/// A view that allows the user to enter a phone number.
struct PhoneNumberEntryView: View {
    @Binding private var e164PhoneNumber: String
    @State private var countryFlag : String = CountryNumbers.defaultCountry.flag
    @State private var countryCode : String = CountryNumbers.defaultCountry.code
    @State private var countryPattern : String = CountryNumbers.defaultCountry.pattern
    @State private var countryLimit : Int = CountryNumbers.defaultCountry.limit
    @State private var phoneNumber = ""
    @State private var searchCountry: String = ""
    @State private var presentSheet = false
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var keyIsFocused: Bool
    
    private var combinedPhoneNumber: String {
        countryCode + removePatternOnNumbers(phoneNumber)
    }
 
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                presentSheet = true
                keyIsFocused = false
            } label: {
                Text("\(countryFlag) \(countryCode)")
                    .foregroundColor(.primary)
                    .padding([.leading, .trailing], 20)
                    .padding([.top, .bottom], 7)
                    .frame(minWidth: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                        #if os(macOS)
                            .fill(Color(nsColor: .tertiarySystemFill))
                        #else
                            .fill(Color(uiColor: .tertiarySystemFill))
                        #endif
                    )
            }
            VerifiableTextField(AccountKeys.phoneNumber.name, text: $phoneNumber)
                .focused($keyIsFocused)
                .textContentType(.telephoneNumber)
#if !os(macOS)
                .keyboardType(.phonePad)
#endif
                .onChange(of: phoneNumber) {
                    applyPatternOnNumbers(&phoneNumber, pattern: countryPattern, replacementCharacter: "#")
                }
                .disableFieldAssistants()
        }
            .onChange(of: combinedPhoneNumber) { _, newValue in
                print(combinedPhoneNumber)
                e164PhoneNumber = newValue
            }
            .sheet(isPresented: $presentSheet) {
                NavigationView {
                    List(filteredCountries) { country in
                        HStack {
                            Text(country.flag)
                            Text(country.name)
                                .font(.headline)
                            Spacer()
                            Text(country.dial_code)
                                .foregroundColor(.secondary)
                        }
                            .onTapGesture {
                                self.countryFlag = country.flag
                                self.countryCode = country.dial_code
                                self.countryPattern = country.pattern
                                self.countryLimit = country.limit
                                presentSheet = false
                                searchCountry = ""
                            }
                    }
                        .listStyle(.plain)
                        .searchable(text: $searchCountry, prompt: "Your country")
                }
                    .presentationDetents([.medium, .large])
            }
                .presentationDetents([.medium, .large])
    }
    
    
    private var filteredCountries: [CountryNumbers.CountryPhoneData] {
        if searchCountry.isEmpty {
            return CountryNumbers.allCountries
        } else {
            return CountryNumbers.allCountries.filter { $0.name.localizedCaseInsensitiveContains(searchCountry) }
        }
    }
    
    private var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
        
    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
    
    private func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
    }

    private func removePatternOnNumbers(_ stringvar: String) -> String {
        return stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
    }
    
    /// Initialize a new `PhoneNumberEntryView`.
    /// - Parameters:
    ///   - phoneNumber: A binding to the phone number state.
    init(
        phoneNumber: Binding<String>
    ) {
        self._phoneNumber = phoneNumber
    }
}
