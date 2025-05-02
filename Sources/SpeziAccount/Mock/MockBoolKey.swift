//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// For internal previews and testing.
@_spi(_Testing)
public struct MockBoolKey: AccountKey {
    public typealias Value = Bool
    public static let name: LocalizedStringResource = "Toggle"
    public static let identifier = "mockBool"
    public static let category: AccountKeyCategory = .other
    public static let options: AccountKeyOptions = .default
}
