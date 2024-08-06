//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


// for internal previews
#if DEBUG
struct MockDoubleKey: AccountKey {
    typealias Value = Double
    static let name: LocalizedStringResource = "Double Key"
    static let identifier = "mockDouble"
    static let category: AccountKeyCategory = .other
}
#endif
