//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import Testing

extension AccountDetails {
    static func mock(id: UUID = UUID(), date: Date = .now) -> AccountDetails {
        var details = AccountDetails()
        details.accountId = id.uuidString
        details.userId = "lelandstanford@stanford.edu"
        details.password = "123456789"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
        details.dateOfBirth = date
        details.genderIdentity = .male
        details.isNewUser = true
        return details
    }
}

func assertDetails(_ details1: AccountDetails, _ details2: AccountDetails, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(details1.accountId == details2.accountId, "accountId \(details1.accountId) not equal to \(details2.accountId)", sourceLocation: sourceLocation)
    #expect(details1.userId == details2.userId, "userId \(details1.userId) not equal to \(details2.userId)", sourceLocation: sourceLocation)
    #expect(details1.password == details2.password, "password \(String(describing: details1.password)) not equal to \(String(describing: details2.password))", sourceLocation: sourceLocation)
    #expect(details1.name == details2.name, "name \(String(describing: details1.name)) not equal to \(String(describing: details2.name))", sourceLocation: sourceLocation)
    #expect(details1.dateOfBirth == details2.dateOfBirth, "dateOfBirth \(String(describing: details1.dateOfBirth)) not equal to \(String(describing: details2.dateOfBirth))", sourceLocation: sourceLocation)
    #expect(details1.genderIdentity == details2.genderIdentity, "genderIdentity \(String(describing: details1.genderIdentity)) not equal to \(String(describing: details2.genderIdentity))", sourceLocation: sourceLocation)
}
