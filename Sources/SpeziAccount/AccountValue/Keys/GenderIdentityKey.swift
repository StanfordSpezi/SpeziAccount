//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension AccountDetails {
    /// The gender identity of a user.
    @AccountKey(
        name: LocalizedStringResource("GENDER_IDENTITY_TITLE", bundle: .atURL(from: .module)),
        category: .personalDetails,
        as: GenderIdentity.self,
        initial: .default(.preferNotToState)
    )
    public var genderIdentity: GenderIdentity?
}


@KeyEntry(\.genderIdentity)
public extension AccountKeys { // swiftlint:disable:this no_extension_access_modifier
}
