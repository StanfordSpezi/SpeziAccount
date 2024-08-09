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
        decoder.userInfo[.accountDetailsKeys] = details.keys

        let data = try encoder.encode(details)
        let decoded = try decoder.decode(AccountDetails.self, from: data)

        XCTAssertDetails(decoded, details)
        XCTAssertFalse(decoded.isNewUser) // flags are never encoded
    }

    func testCodableWithCustomMapping() throws {
        var details = AccountDetails()
        details.genderIdentity = .female

        let mapping: [String: any AccountKey.Type] = [
            "GenderIdentityKey": AccountKeys.genderIdentity
        ]

        let encoder = JSONEncoder()
        encoder.userInfo[.accountKeyIdentifierMapping] = mapping

        let decoder = JSONDecoder()
        decoder.userInfo[.accountDetailsKeys] = [AccountKeys.genderIdentity]
        decoder.userInfo[.accountKeyIdentifierMapping] = mapping


        let data = try encoder.encode(details)
        let string = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertEqual(string, "{\"GenderIdentityKey\":\"female\"}")

        let decoded = try decoder.decode(AccountDetails.self, from: data)

        XCTAssertEqual(decoded.genderIdentity, details.genderIdentity)
    }
}
