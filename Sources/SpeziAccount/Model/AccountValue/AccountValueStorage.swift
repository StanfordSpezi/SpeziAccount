//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO we need a generalized SharedRepository pattern here
//  - stores e.g. the primary account service
//  - stores account service configuration elements (by just pulling them out of the account service
//  - allows for computed account values (e.g., email address source from userId if present, otherwise it may be an optional stored thing?)
//  - It replaces the TypedCollection.swift for `Spezi`
//  - allows for distinct instantiations! (e.g. AccountValue system is different from the Spezi typed storage and different between the shared component storage!)

// TODO rename ?
protocol AnyEntry: Sendable {}

public struct AccountValueStorage: Sendable {
    struct Value<Key: AccountValueKey>: AnyEntry {
        let value: Key.Value
    }

    typealias StorageType = [ObjectIdentifier: AnyEntry]

    var contents: StorageType

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

    public func contains<Key: AccountValueKey>(_ key: Key.Type) -> Bool {
        contents[ObjectIdentifier(key)] != nil
    }

    private func get<Key: AccountValueKey>(_ key: Key.Type) -> Key.Value? {
        // TODO check for Computed AccountValue?
        guard let anyEntry = contents[ObjectIdentifier(key)] else {
            return nil
        }

        guard let value = anyEntry as? Value<Key> else {
            return nil
        }

        return value.value
    }

    private mutating func set<Key: AccountValueKey>(_ key: Key.Type, value: Key.Value?) {
        if let value {
            contents[ObjectIdentifier(key)] = Value<Key>(value: value)
        } else {
            contents[ObjectIdentifier(key)] = nil
        }
    }
}

public protocol AccountValueStorageContainer {
    var storage: AccountValueStorage { get }

    // TODO default subscripts?
}

public protocol ModifiableAccountValueStorageContainer: AccountValueStorageContainer {
    var storage: AccountValueStorage { get set }

    // TODO default subscripts?
}
