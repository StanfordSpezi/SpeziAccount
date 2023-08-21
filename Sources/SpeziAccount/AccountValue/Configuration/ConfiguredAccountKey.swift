//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct ConfiguredAccountKey {
    let configuration: any AccountKeyConfiguration


    // once parameter packs arrive in swift we don't need this extra type and can just use `AccountKeyConfiguration`
    private init<Key: AccountKey>(configuration: AccountKeyConfigurationImpl<Key>) {
        self.configuration = configuration
    }


    public static func requires<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .required))
    }

    @_disfavoredOverload
    public static func collects<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .collected))
    }

    @_disfavoredOverload
    public static func supports<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .supported))
    }

    // sadly we can't make this a compiler error. using `unavailable` makes it unavailable as an overload completely.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func collects<Key: RequiredAccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        requires(keyPath)
    }

    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func supports<Key: RequiredAccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        requires(keyPath)
    }
}
