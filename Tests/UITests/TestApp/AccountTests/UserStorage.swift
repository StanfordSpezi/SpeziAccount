//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount


struct UserStorage {
    private static let dateStyle = Date.FormatStyle()
        .locale(.init(identifier: "de"))
        .year()
        .month(.twoDigits)
        .day(.twoDigits)

    static let supportedKeys = AccountKeyCollection {
        \.userId
        \.password
        \.name
        \.genderIdentity
        \.dateOfBirth
    }

    static let defaultUsername = "lelandstanford"
    static let defaultEmail = "lelandstanford@stanford.edu"

    var userId: String
    var password: String
    var name: PersonNameComponents?
    var genderIdentity: GenderIdentity?
    var dateOfBirth: Date?

    // TODO have account value that is "supported"
    //  => test signup and edit!
    
    
    init(
        userId: String,
        password: String = "StanfordRocks123!",
        name: PersonNameComponents? = PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
        gender: GenderIdentity? = .male,
        dateOfBirth: Date? = try? Date("09.03.1824", strategy: dateStyle)
    ) {
        self.userId = userId
        self.password = password
        self.name = name
        self.genderIdentity = gender
        self.dateOfBirth = dateOfBirth
    }


    mutating func update(_ modifications: AccountModifications) {
        let modifiedDetails = modifications.modifiedDetails
        let removedKeys = modifications.removedAccountDetails

        self.userId = modifiedDetails.storage[UserIdKey.self] ?? userId
        self.password = modifiedDetails.password ?? password
        self.name = modifiedDetails.name ?? name
        self.genderIdentity = modifiedDetails.genderIdentity ?? genderIdentity
        self.dateOfBirth = modifiedDetails.dateOfBrith ?? dateOfBirth

        // user Id cannot be removed!
        if removedKeys.name != nil {
            self.name = nil
        }
        if removedKeys.genderIdentity != nil {
            self.genderIdentity = nil
        }
        if removedKeys.dateOfBrith != nil {
            self.dateOfBirth = nil
        }
    }
}
