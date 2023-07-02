//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public protocol AnyEntry: Sendable {}

struct Entry<Key: AccountValueKey>: AnyEntry {
    let value: Key.Value
}

public struct AccountValueStorage: Sendable {
    typealias StorageType = [ObjectIdentifier: AnyEntry]

    private var contents: StorageType

    init(contents: StorageType = [:]) {
        self.contents = contents
    }

    public subscript<Key: AccountValueKey>(_ key: Key.Type) -> Key.Value {
        get {
            guard let value = get(key) else {
                fatalError("The required AccountValue \(Key.self) was requested but not part of the container!")
            }

            return value
        }
        set {
            set(key, value: newValue)
        }
    }

    public subscript<Key: OptionalAccountValueKey>(_ key: Key.Type) -> Key.Value? {
        get {
            guard let value = get(key) else {
                return nil
            }

            return value
        }
        set {
            set(key, value: newValue)
        }
    }

    private func get<Key: AccountValueKey>(_ key: Key.Type) -> Key.Value? {
        // TODO check for Computed AccountValue?
        guard let value = contents[ObjectIdentifier(key)] as? Key.Value else {
            return nil
        }

        return value
    }

    private mutating func set<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) {
        if let value {
            contents[ObjectIdentifier(key)] = Entry<Key>(value: value)
        } else {
            contents[ObjectIdentifier(key)] = nil
        }
    }
}

public protocol AccountValueStorageContainer {
    init(storage: AccountValueStorage)

    var storage: AccountValueStorage { get }
}

public protocol ModifiableAccountValueStorageContainer: AccountValueStorageContainer {
    var storage: AccountValueStorage { get set }
}
