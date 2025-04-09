//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A struct that provides country phone code data for international phone numbers.
public struct CountryNumbers {
    /// Country phone data for individual countries.
    public struct CountryPhoneData: Codable, Identifiable, Hashable, Sendable {
        /// Unique identifier for the country.
        public let id: String
        /// Country name.
        public let name: String
        /// Country flag emoji.
        public let flag: String
        /// ISO country code.
        public let code: String
        /// International dialing code (e.g., "+1").
        public let dial_code: String
        /// Formatting pattern for display (e.g., "### ### ####").
        public let pattern: String
        /// Maximum character limit including formatting.
        public let limit: Int
        
        public init(id: String, name: String, flag: String, code: String, dial_code: String, pattern: String, limit: Int) {
            self.id = id
            self.name = name
            self.flag = flag
            self.code = code
            self.dial_code = dial_code
            self.pattern = pattern
            self.limit = limit
        }
    }
    
    /// All available country phone data.
    public static let allCountries: [CountryPhoneData] = [
        CountryPhoneData(id: "1", name: "United States", flag: "🇺🇸", code: "US", dial_code: "+1", pattern: "### ### ####", limit: 17),
        CountryPhoneData(id: "2", name: "Canada", flag: "🇨🇦", code: "CA", dial_code: "+1", pattern: "### ### ####", limit: 17),
        CountryPhoneData(id: "3", name: "United Kingdom", flag: "🇬🇧", code: "GB", dial_code: "+44", pattern: "#### ######", limit: 16),
        CountryPhoneData(id: "4", name: "Australia", flag: "🇦🇺", code: "AU", dial_code: "+61", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "5", name: "Germany", flag: "🇩🇪", code: "DE", dial_code: "+49", pattern: "### #######", limit: 16),
        CountryPhoneData(id: "6", name: "France", flag: "🇫🇷", code: "FR", dial_code: "+33", pattern: "# ## ## ## ##", limit: 17),
        CountryPhoneData(id: "7", name: "Italy", flag: "🇮🇹", code: "IT", dial_code: "+39", pattern: "### ######", limit: 15),
        CountryPhoneData(id: "8", name: "Spain", flag: "🇪🇸", code: "ES", dial_code: "+34", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "9", name: "Japan", flag: "🇯🇵", code: "JP", dial_code: "+81", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "10", name: "China", flag: "🇨🇳", code: "CN", dial_code: "+86", pattern: "### #### ####", limit: 17),
        CountryPhoneData(id: "11", name: "India", flag: "🇮🇳", code: "IN", dial_code: "+91", pattern: "#### ### ###", limit: 16),
        CountryPhoneData(id: "12", name: "Brazil", flag: "🇧🇷", code: "BR", dial_code: "+55", pattern: "## #### ####", limit: 16),
        CountryPhoneData(id: "13", name: "Mexico", flag: "🇲🇽", code: "MX", dial_code: "+52", pattern: "## ## ####", limit: 15),
        CountryPhoneData(id: "14", name: "South Korea", flag: "🇰🇷", code: "KR", dial_code: "+82", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "15", name: "Russia", flag: "🇷🇺", code: "RU", dial_code: "+7", pattern: "### ### ## ##", limit: 17),
        CountryPhoneData(id: "16", name: "Argentina", flag: "🇦🇷", code: "AR", dial_code: "+54", pattern: "## #### ####", limit: 16),
        CountryPhoneData(id: "17", name: "South Africa", flag: "🇿🇦", code: "ZA", dial_code: "+27", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "18", name: "Singapore", flag: "🇸🇬", code: "SG", dial_code: "+65", pattern: "#### ####", limit: 14),
        CountryPhoneData(id: "19", name: "New Zealand", flag: "🇳🇿", code: "NZ", dial_code: "+64", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "20", name: "Sweden", flag: "🇸🇪", code: "SE", dial_code: "+46", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "21", name: "Netherlands", flag: "🇳🇱", code: "NL", dial_code: "+31", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "22", name: "Switzerland", flag: "🇨🇭", code: "CH", dial_code: "+41", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "23", name: "Norway", flag: "🇳🇴", code: "NO", dial_code: "+47", pattern: "### ## ###", limit: 14),
        CountryPhoneData(id: "24", name: "Denmark", flag: "🇩🇰", code: "DK", dial_code: "+45", pattern: "## ## ## ##", limit: 15),
        CountryPhoneData(id: "25", name: "Finland", flag: "🇫🇮", code: "FI", dial_code: "+358", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "26", name: "Belgium", flag: "🇧🇪", code: "BE", dial_code: "+32", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "27", name: "Austria", flag: "🇦🇹", code: "AT", dial_code: "+43", pattern: "### ###-####", limit: 16),
        CountryPhoneData(id: "28", name: "Ireland", flag: "🇮🇪", code: "IE", dial_code: "+353", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "29", name: "Poland", flag: "🇵🇱", code: "PL", dial_code: "+48", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "30", name: "Portugal", flag: "🇵🇹", code: "PT", dial_code: "+351", pattern: "### ### ###", limit: 16),
        CountryPhoneData(id: "31", name: "Greece", flag: "🇬🇷", code: "GR", dial_code: "+30", pattern: "### ### ####", limit: 15),
        CountryPhoneData(id: "32", name: "Israel", flag: "🇮🇱", code: "IL", dial_code: "+972", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "33", name: "Turkey", flag: "🇹🇷", code: "TR", dial_code: "+90", pattern: "### ### ####", limit: 15),
        CountryPhoneData(id: "34", name: "Saudi Arabia", flag: "🇸🇦", code: "SA", dial_code: "+966", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "35", name: "United Arab Emirates", flag: "🇦🇪", code: "AE", dial_code: "+971", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "36", name: "Egypt", flag: "🇪🇬", code: "EG", dial_code: "+20", pattern: "### ### ####", limit: 15),
        CountryPhoneData(id: "37", name: "Thailand", flag: "🇹🇭", code: "TH", dial_code: "+66", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "38", name: "Malaysia", flag: "🇲🇾", code: "MY", dial_code: "+60", pattern: "## ### ####", limit: 15),
        CountryPhoneData(id: "39", name: "Indonesia", flag: "🇮🇩", code: "ID", dial_code: "+62", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "40", name: "Philippines", flag: "🇵🇭", code: "PH", dial_code: "+63", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "41", name: "Vietnam", flag: "🇻🇳", code: "VN", dial_code: "+84", pattern: "## #### ####", limit: 16),
        CountryPhoneData(id: "42", name: "Pakistan", flag: "🇵🇰", code: "PK", dial_code: "+92", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "43", name: "Bangladesh", flag: "🇧🇩", code: "BD", dial_code: "+880", pattern: "### ### ###", limit: 16),
        CountryPhoneData(id: "44", name: "Nigeria", flag: "🇳🇬", code: "NG", dial_code: "+234", pattern: "### ### ####", limit: 17),
        CountryPhoneData(id: "45", name: "Kenya", flag: "🇰🇪", code: "KE", dial_code: "+254", pattern: "### ### ###", limit: 16),
        CountryPhoneData(id: "46", name: "Ghana", flag: "🇬🇭", code: "GH", dial_code: "+233", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "47", name: "Morocco", flag: "🇲🇦", code: "MA", dial_code: "+212", pattern: "## #### ###", limit: 16),
        CountryPhoneData(id: "48", name: "Algeria", flag: "🇩🇿", code: "DZ", dial_code: "+213", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "49", name: "Tunisia", flag: "🇹🇳", code: "TN", dial_code: "+216", pattern: "## ### ###", limit: 15),
        CountryPhoneData(id: "50", name: "Peru", flag: "🇵🇪", code: "PE", dial_code: "+51", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "51", name: "Colombia", flag: "🇨🇴", code: "CO", dial_code: "+57", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "52", name: "Chile", flag: "🇨🇱", code: "CL", dial_code: "+56", pattern: "# #### ####", limit: 15),
        CountryPhoneData(id: "53", name: "Venezuela", flag: "🇻🇪", code: "VE", dial_code: "+58", pattern: "### ### ####", limit: 16),
        CountryPhoneData(id: "54", name: "Cuba", flag: "🇨🇺", code: "CU", dial_code: "+53", pattern: "# ### ####", limit: 14),
        CountryPhoneData(id: "55", name: "Czech Republic", flag: "🇨🇿", code: "CZ", dial_code: "+420", pattern: "### ### ###", limit: 16),
        CountryPhoneData(id: "56", name: "Hungary", flag: "🇭🇺", code: "HU", dial_code: "+36", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "57", name: "Ukraine", flag: "🇺🇦", code: "UA", dial_code: "+380", pattern: "## ### ####", limit: 16),
        CountryPhoneData(id: "58", name: "Romania", flag: "🇷🇴", code: "RO", dial_code: "+40", pattern: "### ### ###", limit: 15),
        CountryPhoneData(id: "59", name: "Bulgaria", flag: "🇧🇬", code: "BG", dial_code: "+359", pattern: "### ### ###", limit: 16),
        CountryPhoneData(id: "60", name: "Croatia", flag: "🇭🇷", code: "HR", dial_code: "+385", pattern: "## ### ###", limit: 15)
    ]
    
    /// Get country data by ISO country code.
    /// - Parameter code: The ISO country code (e.g., "US", "GB")
    /// - Returns: The corresponding CountryPhoneData if found, nil otherwise
    public static func country(byCode code: String) -> CountryPhoneData? {
        allCountries.first { $0.code.uppercased() == code.uppercased() }
    }
    
    /// Get country data by dial code.
    /// - Parameter dialCode: The international dialing code (e.g., "+1", "+44")
    /// - Returns: The corresponding CountryPhoneData if found, nil otherwise
    public static func country(byDialCode dialCode: String) -> CountryPhoneData? {
        allCountries.first { $0.dial_code == dialCode }
    }
    
    /// Get all countries sorted by name.
    /// - Returns: Array of CountryPhoneData sorted alphabetically by country name
    public static func countriesSortedByName() -> [CountryPhoneData] {
        allCountries.sorted { $0.name < $1.name }
    }
    
    /// The default country (United States).
    public static var defaultCountry: CountryPhoneData {
        allCountries.first { $0.code == "US" }!
    }
}
