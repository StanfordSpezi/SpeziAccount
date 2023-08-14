//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct ConfiguredAccountValue {
    let configuration: AnyAccountValueConfigurationEntry


    // once Parameter Packs are available, we can replace this type with just `AccountValueConfigurationEntry` (by renaming it)
    // and moving below static methods into the `AccountValueConfigurationEntry` type.
    private init<Key: AccountValueKey>(configuration: AccountValueConfigurationEntry<Key>) {
        self.configuration = configuration
    }


    // TODO do we need non-keyPath equivalents?
    public static func requires<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> ConfiguredAccountValue {
        .init(configuration: AccountValueConfigurationEntry(Key.self, type: .required))
    }

    @_disfavoredOverload
    public static func collects<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> ConfiguredAccountValue {
        .init(configuration: AccountValueConfigurationEntry(Key.self, type: .collected))
    }

    @_disfavoredOverload
    public static func supports<Key: AccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> ConfiguredAccountValue {
        .init(configuration: AccountValueConfigurationEntry(Key.self, type: .supported))
    }

    // sadly we can't make this a compiler error. using `unavailable` makes it unavailable as an overload completely.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountValueKey' must always be supplied as required using requires(_:)")
    public static func collects<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> ConfiguredAccountValue {
        requires(keyPath)
    }

    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountValueKey' must always be supplied as required using requires(_:)")
    public static func supports<Key: RequiredAccountValueKey>(_ keyPath: KeyPath<AccountValueKeys, Key.Type>) -> ConfiguredAccountValue {
        requires(keyPath)
    }
}
