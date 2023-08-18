//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public protocol AnyAccountValueConfigurationEntry: CustomStringConvertible, CustomDebugStringConvertible {
    var anyKey: any AccountValueKey.Type { get }
    var requirement: AccountValueRequirement { get }

    var id: ObjectIdentifier { get }

    func isContained<Storage: AccountValueStorageContainer>(in container: Storage) -> Bool
}


struct AccountValueConfigurationEntry<Key: AccountValueKey>: AnyAccountValueConfigurationEntry {
    public let key: Key.Type
    public let requirement: AccountValueRequirement


    init(_ key: Key.Type, type: AccountValueRequirement) {
        self.key = key
        self.requirement = type
    }
}


extension AccountValueConfigurationEntry: CustomDebugStringConvertible {
    public var id: ObjectIdentifier {
        key.id
    }

    public var anyKey: any AccountValueKey.Type {
        key
    }

    public var description: String {
        "\(Key.self)"
    }

    public var debugDescription: String {
        var name = Key.name
        name.locale = .init(identifier: "en_US")
        // TODO it is not a requirement that userId matches the property name (or not documented)!
        //   => also it must be lower-cased!

        // TODO => use the description of the KeyPath implementation!
        //   see https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
        switch requirement {
        case .required:
            return ".requires(\\.\(name))"
        case .collected:
            return ".collects(\\.\(name))"
        case .supported:
            return ".supports(\\.\(name))"
        }
    }

    public func isContained<Storage: AccountValueStorageContainer>(in container: Storage) -> Bool {
        Key.isContained(in: container)
    }
}
