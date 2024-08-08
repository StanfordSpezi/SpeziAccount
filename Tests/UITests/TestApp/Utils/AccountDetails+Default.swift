//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount


extension AccountDetails {
    private static let dateStyle = Date.FormatStyle()
        .locale(.init(identifier: "de"))
        .year()
        .month(.twoDigits)
        .day(.twoDigits)

    static var defaultDetails: AccountDetails {
        var details = AccountDetails()
        details.userId = "lelandstanford@stanford.edu"
        details.password = "StanfordRocks123!"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
        details.genderIdentity = .male
        details.dateOfBirth = try? Date("09.03.1824", strategy: dateStyle)
        return details
    }
}
