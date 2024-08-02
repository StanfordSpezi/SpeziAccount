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
struct MockBoolKey: AccountKey {
    typealias Value = Bool
    static let name: LocalizedStringResource = "Toggle"
    static let identifier = "mockBool"
    static let category: AccountKeyCategory = .other
    static let initialValue: InitialValue<Bool> = .default(false) // TODO: default! extension
}
#endif
