//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


enum AccountInputFields: Hashable { // TODO find a extendable alternative!
    case userId
    case password
    case passwordRepeat // TODO remove!
    case givenName
    case familyName
    case genderIdentity
    case dateOfBirth
    case phoneNumber
}
