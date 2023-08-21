//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// TODO double the any word!
public protocol AnyAccountValueConfigurationEntry: CustomStringConvertible, CustomDebugStringConvertible, Identifiable, Hashable
    where ID == ObjectIdentifier {
    associatedtype Key: AccountValueKey

    var key: Key.Type { get }
    var requirement: AccountValueRequirement { get }

    func isContained<Storage: AccountValueStorageContainer>(in container: Storage) -> Bool
}


struct AccountValueConfigurationEntry<Key: AccountValueKey>: AnyAccountValueConfigurationEntry {
    let key: Key.Type
    let requirement: AccountValueRequirement

    let keyPathDescription: String

    init(_ keyPath: KeyPath<AccountValueKeys, Key.Type>, type: AccountValueRequirement) {
        self.key = Key.self
        self.requirement = type
        self.keyPathDescription = keyPath.shortDescription
    }
}


extension AccountValueConfigurationEntry {
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

    static func == (lhs: AccountValueConfigurationEntry<Key>, rhs: AccountValueConfigurationEntry<Key>) -> Bool {
        lhs.id == rhs.id
    }


    func isContained<Storage: AccountValueStorageContainer>(in container: Storage) -> Bool {
        Key.isContained(in: container)
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
