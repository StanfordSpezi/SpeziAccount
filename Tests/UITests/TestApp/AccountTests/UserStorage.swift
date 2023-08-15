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
    var userId: String
    var name = PersonNameComponents()
    var gender: GenderIdentity?
    var dateOfBirth: Date?

    // TODO have account value that is "supported"
    //  => test signup and edit!
    
    
    init(
        userId: String = "lelandstanford",
        name: PersonNameComponents = PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
        gender: GenderIdentity? = .male,
        dateOfBirth: Date? = Date() // TODO 9. März 1824
    ) {
        self.userId = userId
        self.name = name
        self.gender = gender
        self.dateOfBirth = dateOfBirth
    }
}
