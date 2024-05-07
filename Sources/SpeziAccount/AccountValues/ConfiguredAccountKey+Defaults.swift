//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AccountValues


extension AccountValueConfiguration {
    /// The default set of ``ConfiguredAccountKey``s that `SpeziAccount` provides.
    public static let `default` = AccountValueConfiguration(.default)
}


extension Array where Element == ConfiguredAccountKey { // TODO: move somewhere?
    /// The default array of ``ConfiguredAccountKey``s that `SpeziAccount` provides.
    public static let `default`: [ConfiguredAccountKey] = [
        .requires(\.userId),
        .requires(\.password),
        .requires(\.name),
        .collects(\.dateOfBirth),
        .collects(\.genderIdentity)
    ]
}
