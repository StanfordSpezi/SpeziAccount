//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import Spezi


/// A list of ``ValidationRule`` to validate the input for String-based ``AccountKey``s.
///
/// You can use this configuration to set up ``ValidationRule`` used by an ``ValidationEngine`` for any string-based
/// ``AccountKey``. Input fields (e.g., placed in signup or edit forms) use those rules to validate the received string input
/// against the provided value.
///
/// Below is a minimal code example on how to configure ``ValidationRule``s for the `userId` and `password` account values:
/// ```swift
/// public actor SomeAccountService: AccountService {
///     public let configuration = AccountServiceConfiguration(name: "Some name") {
///         FieldValidationRules(for: \.userId, rules: .interceptingChain(.nonEmpty), .minimalEmail)
///         FieldValidationRules(for: \.password, rules: .interceptingChain(.nonEmpty), .strongPassword)
///     }
/// }
/// ```
///
/// - Note: When using built-in views like ``SignupForm`` that use the ``GeneralizedDataEntryView``, a ``ValidationEngine``
///     with the configured validation rules is automatically injected using the ``SwiftUI/View/managedValidation(input:for:rules:)-5gj5g``
///     or ``SwiftUI/View/managedValidation(input:for:rules:)-zito``  modifier.
///
/// ### Default Values
/// The configuration provides the following default validation rules depending on the context:
/// * ``ValidationRule/nonEmpty`` (intercepting) and ``ValidationRule/minimalEmail`` if the `Key` is of type ``UserIdKey`` and the user id type is ``UserIdType/emailAddress``
///     or if the `Key` is of type ``EmailAddressKey``.
/// * ``ValidationRule/nonEmpty`` (intercepting) and ``ValidationRule/minimalPassword`` if the `Key` is of type ``PasswordKey``.
/// * ``ValidationRule/nonEmpty`` otherwise.
public struct FieldValidationRules<Key: AccountKey>: AccountServiceConfigurationKey, OptionalComputedKnowledgeSource where Key.Value == String {
    // We use always compute, as we don't want our computation result to get stored. We don't have a mutable view anyways.
    public typealias StoragePolicy = AlwaysCompute

    /// The ``AccountKey`` type for which this instance provides validation rules.
    public let key: Key.Type
    /// The list of ``ValidationRule`` a new value is validated against.
    public let validationRules: [ValidationRule]


    /// Initialize a new `FieldValidationRules`.
    /// - Parameters:
    ///   - key: The ``AccountKey`` type.
    ///   - validationRules: The array of ``ValidationRule``s.
    public init(for key: Key.Type, rules validationRules: [ValidationRule]) {
        self.key = key
        self.validationRules = validationRules
    }

    /// Initialize a new `FieldValidationRules`.
    /// - Parameters:
    ///   - key: The ``AccountKey`` type.
    ///   - validationRules: The array of ``ValidationRule``s supplied as variadic arguments.
    public init(for key: Key.Type, rules validationRules: ValidationRule...) {
        self.init(for: key, rules: validationRules)
    }

    /// Initialize a new `FieldValidationRules`.
    /// - Parameters:
    ///   - keyPath: The ``AccountKey`` type supplied as a `KeyPath`.
    ///   - validationRules: The array of ``ValidationRule``s.
    public init(for keyPath: KeyPath<AccountKeys, Key.Type>, rules validationRules: [ValidationRule]) {
        self.init(for: Key.self, rules: validationRules)
    }

    /// Initialize a new `FieldValidationRules`.
    /// - Parameters:
    ///   - keyPath: The ``AccountKey`` type supplied as a `KeyPath`.
    ///   - validationRules: The array of ``ValidationRule``s supplied as variadic arguments.
    public init(for keyPath: KeyPath<AccountKeys, Key.Type>, rules validationRules: ValidationRule...) {
        self.init(for: Key.self, rules: validationRules)
    }


    public static func compute<Repository: SharedRepository<Anchor>>(from repository: Repository) -> FieldValidationRules<Key>? {
        if let value = repository.get(Self.self) {
            return value // either the user configured a value themselves
        }

        // or we return a default based on the Key type and the current configuration environment
        if Key.self == UserIdKey.self && repository[UserIdConfiguration.self].idType == .emailAddress
            || Key.self == EmailAddressKey.self {
            return FieldValidationRules(for: Key.self, rules: .nonEmpty.intercepting, .minimalEmail)
        } else if Key.self == PasswordKey.self {
            return FieldValidationRules(for: Key.self, rules: .nonEmpty.intercepting, .minimalPassword)
        } else {
            // we cannot statically determine here if the user may have configured the Key to be required
            return nil
        }
    }
}


extension AccountServiceConfiguration {
    /// Access the validation rules for String-based ``AccountKey`` configured by an ``AccountService``.
    /// - Parameter key: The ``AccountKey`` type.
    /// - Returns: The array of ``ValidationRule``s.
    public func fieldValidationRules<Key: AccountKey>(for key: Key.Type) -> [ValidationRule]? where Key.Value == String {
        storage[FieldValidationRules<Key>.self]?.validationRules
    }

    /// Access the validation rules for String-based ``AccountKey`` configured by an ``AccountService``.
    /// - Parameter keyPath: The ``AccountKey`` type supplied as `KeyPath`.
    /// - Returns: The array of ``ValidationRule``s.
    public func fieldValidationRules<Key: AccountKey>(
        for keyPath: KeyPath<AccountKeys, Key.Type>
    ) -> [ValidationRule]? where Key.Value == String {
        fieldValidationRules(for: Key.self)
    }
}
