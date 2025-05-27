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
    @AccountKey(name: "Display-Only", options: .display, as: String.self)
    var displayOnlyOption: String?

    @AccountKey(name: "Mutable-Only", options: .mutable, as: String.self)
    var mutableOnlyOption: String?
}


@KeyEntry(\.displayOnlyOption)
@KeyEntry(\.mutableOnlyOption)
extension AccountKeys {}
