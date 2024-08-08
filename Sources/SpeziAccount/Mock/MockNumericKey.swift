//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


// for internal previews
struct MockNumericKey: AccountKey {
    typealias Value = Int
    static let name: LocalizedStringResource = "Numeric Key"
    static let identifier = "mockNumeric"
    static let category: AccountKeyCategory = .other
}
