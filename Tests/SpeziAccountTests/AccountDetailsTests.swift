//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import SpeziAccount
import SpeziAccountPhoneNumbers
import Testing

@Suite("AccountDetails General Tests")
struct AccountDetailsTests {
    @Test
    func testCodable() throws {
        let details: AccountDetails = .mock()

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let configuration = AccountDetails.DecodingConfiguration(keys: details.keys)

        let data = try encoder.encode(details)
        let decoded = try decoder.decode(AccountDetails.self, from: data, configuration: configuration)

        assertDetails(decoded, details)
        #expect(decoded.isNewUser == false) // flags are never encoded
    }

    @Test
    func testCodableWithCustomMapping() throws {
        var details = AccountDetails()
        details.genderIdentity = .female

        let mapping: [String: any AccountKey.Type] = [
            "GenderIdentityKey": AccountKeys.genderIdentity
        ]

        let encodingConfiguration = AccountDetails.EncodingConfiguration(identifierMapping: mapping)
        let decodingConfiguration = AccountDetails.DecodingConfiguration(
            keys: [AccountKeys.genderIdentity],
            identifierMapping: mapping
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(details, configuration: encodingConfiguration)
        let string = try #require(String(data: data, encoding: .utf8))
        #expect(string == "{\"GenderIdentityKey\":\"female\"}")

        let decoded = try decoder.decode(AccountDetails.self, from: data, configuration: decodingConfiguration)

        #expect(decoded.genderIdentity == details.genderIdentity)
    }

    @Test
    func testUserIdKeyFallback() throws {
        var details = AccountDetails()
        details.accountId = "Hello World"

        #expect(details.userId == "Hello World")
    }

    @Test
    func testEmailKey() throws {
        var details = AccountDetails()
        details.userId = "username@example.org"
        details[AccountDetails.AccountServiceConfigurationDetailsKey.self] = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            UserIdConfiguration.emailAddress
        }
        details.email = "example@example.org"

        #expect(details.email == "example@example.org")
        details.email = nil
        #expect(details[AccountDetails.__Key_email.self] == "username@example.org")
        #expect(details.email == "username@example.org")
        // test missing config
        #expect(AccountDetails().email == nil)

        var usernameDetails = AccountDetails()
        usernameDetails.userId = "username"
        usernameDetails[AccountDetails.AccountServiceConfigurationDetailsKey.self] = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            UserIdConfiguration.username
        }
        #expect(usernameDetails.email == nil)
    }

    @Test
    func testPhoneNumbersKey() throws {
        var details = AccountDetails()
        details.phoneNumbers = ["+16501234567"]
        #expect(details.phoneNumbers == ["+16501234567"])
        
        details.phoneNumbers = nil
        #expect(details.phoneNumbers == nil)
    }
}
