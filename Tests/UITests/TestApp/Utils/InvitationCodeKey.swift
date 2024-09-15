//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

extension AccountDetails {
    @AccountKey(name: "Invitation Code", category: .other, as: String.self)
    var invitationCode: String?
}


@KeyEntry(\.invitationCode)
extension AccountKeys {}
