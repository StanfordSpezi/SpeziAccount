//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A wrapper for ``AccountKeyConfiguration`` that provides accessors to create new configuration entries.
///
/// Below is a code example demonstrating how you could instantiate new configuration entries.
///
/// ```swift
/// let configurations: [ConfiguredAccountKey] = [
///     .requires(\.userId),
///     .requires(\.password),
///     .collects(\.name),
///     .supported(\.genderIdentity)
/// ]
/// ```
///
/// ## Topics
///
/// ### Configuration
/// - ``Swift/Array/default``
public struct ConfiguredAccountKey {
    let configuration: any AccountKeyConfiguration


    // once parameter packs arrive in swift we don't need this extra type and can just use `AccountKeyConfiguration`
    private init<Key: AccountKey>(configuration: AccountKeyConfigurationImpl<Key>) {
        self.configuration = configuration
    }


    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required``.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: Returns the ``AccountKey`` configuration.
    public static func requires<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .required))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/collected``.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @_disfavoredOverload
    public static func collects<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .collected))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/supported``.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @_disfavoredOverload
    public static func supports<Key: AccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        .init(configuration: AccountKeyConfigurationImpl(keyPath, type: .supported))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required`` as ``RequiredAccountKey`` can only be configured as required.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func collects<Key: RequiredAccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        // sadly we can't make this a compiler error. using `unavailable` makes it unavailable as an overload completely.
        requires(keyPath)
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required`` as ``RequiredAccountKey`` can only be configured as required.
    /// - Parameter keyPath: The `KeyPath` referencing the ``AccountKey``.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func supports<Key: RequiredAccountKey>(_ keyPath: KeyPath<AccountKeys, Key.Type>) -> ConfiguredAccountKey {
        requires(keyPath)
    }
}
