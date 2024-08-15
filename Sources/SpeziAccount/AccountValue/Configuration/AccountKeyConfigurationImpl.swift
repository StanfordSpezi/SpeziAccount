//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A user-configured ``AccountKey``.
public protocol AccountKeyConfiguration: CustomStringConvertible, CustomDebugStringConvertible, Identifiable, Hashable, Sendable
    where ID == ObjectIdentifier {
    /// The associated ``AccountKey``.
    associatedtype Key: AccountKey

    /// Access the ``AccountKey`` meta-type.
    var key: Key.Type { get }

    /// The requirement level that was defined for the ``AccountKey``.
    var requirement: AccountKeyRequirement { get }

    /// A user-friendly, human-readable string description that resembles the `KeyPath` description.
    var keyPathDescription: String { get }
}


struct AccountKeyConfigurationImpl<Key: AccountKey>: AccountKeyConfiguration {
    let key: Key.Type
    let requirement: AccountKeyRequirement

    let keyPathDescription: String

    init(_ keyPath: KeyPath<AccountKeys, Key.Type>, type: AccountKeyRequirement) {
        self.key = Key.self
        self.requirement = type
        self.keyPathDescription = keyPath.shortDescription
    }
}


extension AccountKeyConfiguration {
    var keyWithDescription: any AccountKeyWithDescription {
        AccountKeyWithKeyPathDescription(key: key, description: keyPathDescription)
    }
}


extension AccountKeyConfigurationImpl {
    var id: ObjectIdentifier {
        key.id
    }

    var description: String {
        switch requirement {
        case .required:
            return ".requires(\(keyPathDescription))"
        case .collected:
            return ".collects(\(keyPathDescription))"
        case .supported:
            return ".supports(\(keyPathDescription))"
        }
    }

    var debugDescription: String {
        description
    }


    static func == (lhs: AccountKeyConfigurationImpl<Key>, rhs: AccountKeyConfigurationImpl<Key>) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
