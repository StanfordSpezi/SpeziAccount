//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


@_spi(TestingSupport)
extension AccountDetails {
    static func createMock(
        id: String = UUID().uuidString,
        userId: String = "lelandstanford@stanford.edu",
        name: PersonNameComponents? = PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
        genderIdentity: GenderIdentity? = nil,
        dateOfBirth: Date? = nil
    ) -> AccountDetails {
        var details = AccountDetails()
        details.accountId = id
        details.userId = userId
        details.name = name
        details.genderIdentity = genderIdentity
        details.dateOfBirth = dateOfBirth
        return details
    }
}
