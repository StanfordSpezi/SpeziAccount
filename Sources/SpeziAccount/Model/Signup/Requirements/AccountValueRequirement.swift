//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public protocol AnyAccountValueRequirement: CustomStringConvertible {
    var type: AccountValueType { get }
    var id: ObjectIdentifier { get }

    var anyKey: any AccountValueKey.Type { get }

    func isContained(in storage: AccountValueStorage) -> Bool
}


struct AccountValueRequirement<Key: AccountValueKey>: AnyAccountValueRequirement, Identifiable {
    let type: AccountValueType

    var id: ObjectIdentifier {
        Key.id
    }

    var anyKey: any AccountValueKey.Type {
        Key.self
    }

    var description: String {
        "\(Key.self)"
    }

    init(type: AccountValueType) {
        self.type = type
    }

    func isContained(in storage: AccountValueStorage) -> Bool {
        storage.contains(Key.self)
    }
}
