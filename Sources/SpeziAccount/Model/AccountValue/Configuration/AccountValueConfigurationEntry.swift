//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public protocol AnyAccountValueConfigurationEntry: CustomStringConvertible {
    var anyKey: any AccountValueKey.Type { get }
    var requirement: AccountValueRequirement { get }

    var id: ObjectIdentifier { get }

    func isContained(in storage: AccountValueStorage) -> Bool
}


struct AccountValueConfigurationEntry<Key: AccountValueKey>: AnyAccountValueConfigurationEntry {
    public let key: Key.Type
    public let requirement: AccountValueRequirement


    init(_ key: Key.Type, type: AccountValueRequirement) {
        self.key = key
        self.requirement = type
    }
}


extension AccountValueConfigurationEntry {
    public var id: ObjectIdentifier {
        key.id
    }

    public var anyKey: any AccountValueKey.Type {
        key
    }

    public var description: String {
        "\(Key.self)"
    }


    public func isContained(in storage: AccountValueStorage) -> Bool {
        storage.contains(Key.self)
    }
}