//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public protocol AnyAccountValueRequirement: CustomStringConvertible {
    var type: AccountValueType { get }
    var id: ObjectIdentifier { get }

    func isContained(in storage: AccountValueStorage) -> Bool
}

struct AccountValueRequirement<Key: AccountValueKey>: AnyAccountValueRequirement {
    let type: AccountValueType
    var id: ObjectIdentifier {
        ObjectIdentifier(Key.self)
    }

    var description: String {
        "\(Key.self)"
    }

    public init(type: AccountValueType) {
        self.type = type
    }

    func isContained(in storage: AccountValueStorage) -> Bool {
        storage.contains(Key.self)
    }
}
