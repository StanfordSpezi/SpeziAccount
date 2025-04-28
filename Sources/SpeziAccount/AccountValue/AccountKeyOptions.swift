//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct AccountKeyOptions: OptionSet { // TODO: docs!
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
}


extension AccountKeyOptions: Hashable, Sendable, Codable {}


extension AccountKeyOptions {
    public static let read = AccountKeyOptions(rawValue: 1 << 0)
    public static let write = AccountKeyOptions(rawValue: 1 << 1)

    public static let `default`: AccountKeyOptions = [.read, .write]
}
