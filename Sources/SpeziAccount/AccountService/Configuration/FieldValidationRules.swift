//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi

// TODO docs

public struct FieldValidationRules<Key: AccountValueKey>: AccountServiceConfigurationKey, ComputedKnowledgeSource where Key.Value == String {
    public typealias StoragePolicy = AlwaysCompute

    public let key: Key.Type
    public let validationRules: [ValidationRule]


    public init(for key: Key.Type, rules validationRules: [ValidationRule]) {
        self.key = key
        self.validationRules = validationRules
    }

    public init(for keyPath: KeyPath<AccountValueKeys, Key.Type>, rules validationRules: [ValidationRule]) {
        self.init(for: Key.self, rules: validationRules)
    }


    public static func compute<Repository: SharedRepository<Anchor>>(from repository: Repository) -> FieldValidationRules<Key> {
        if let value = repository.get(Self.self) {
            return value // either the user configured a value themselves
        }

        // or we return a default based on the Key type and the current configuration environment
        if Key.self == UserIdKey.self && repository[UserIdConfiguration.self].idType == .emailAddress {
            return FieldValidationRules(for: Key.self, rules: [.interceptingChain(.nonEmpty), .minimalEmail])
        } else if Key.self == PasswordKey.self {
            return FieldValidationRules(for: Key.self, rules: [.interceptingChain(.nonEmpty), .minimalPassword])
        } else {
            return FieldValidationRules(for: Key.self, rules: [.interceptingChain(.nonEmpty)])
        }
    }
}


extension AccountServiceConfiguration {
    public func fieldValidationRules<Key: AccountValueKey>(for key: Key.Type) -> [ValidationRule] where Key.Value == String {
        storage[FieldValidationRules<Key>.self].validationRules
    }

    public func fieldValidationRules<Key: AccountValueKey>(
        for keyPath: KeyPath<AccountValueKeys, Key.Type>
    ) -> [ValidationRule] where Key.Value == String {
        fieldValidationRules(for: Key.self)
    }
}
