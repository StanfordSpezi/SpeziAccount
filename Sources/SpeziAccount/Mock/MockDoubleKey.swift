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
public struct MockDoubleKey: AccountKey {
    public typealias Value = Double
    public static let name: LocalizedStringResource = "Double Key"
    public static let identifier = "mockDouble"
    public static let category: AccountKeyCategory = .other
}
