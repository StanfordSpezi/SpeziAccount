//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziAccount
import XCTest


final class AccountDetailsTests: XCTestCase {
    func testCodable() throws {
        let details: AccountDetails = .mock()

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let configuration = AccountDetails.DecodingConfiguration(keys: details.keys)

        let data = try encoder.encode(details)
        let decoded = try decoder.decode(AccountDetails.self, from: data, configuration: configuration)

        XCTAssertDetails(decoded, details)
        XCTAssertFalse(decoded.isNewUser) // flags are never encoded
    }

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
        let string = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertEqual(string, "{\"GenderIdentityKey\":\"female\"}")

        let decoded = try decoder.decode(AccountDetails.self, from: data, configuration: decodingConfiguration)

        XCTAssertEqual(decoded.genderIdentity, details.genderIdentity)
    }


    func testUserIdKeyFallback() throws {
        var details = AccountDetails()
        details.accountId = "Hello World"

        XCTAssertEqual(details.userId, "Hello World")
    }

    func testEmailKey() throws {
        var details = AccountDetails()
        details.userId = "username@example.org"
        details[AccountDetails.AccountServiceConfigurationDetailsKey.self] = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            UserIdConfiguration.emailAddress
        }
        details.email = "example@example.org"

        XCTAssertEqual(details.email, "example@example.org")
        details.email = nil
        XCTAssertEqual(details[AccountDetails.__Key_email.self], "username@example.org")
        XCTAssertEqual(details.email, "username@example.org")

        // test missing config
        XCTAssertNil(AccountDetails().email)

        var usernameDetails = AccountDetails()
        usernameDetails.userId = "username"
        usernameDetails[AccountDetails.AccountServiceConfigurationDetailsKey.self] = AccountServiceConfiguration(supportedKeys: .arbitrary) {
            UserIdConfiguration.username
        }
        XCTAssertNil(usernameDetails.email)
    }
}
