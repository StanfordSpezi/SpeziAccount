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
    /// - Returns: Returns the ``AccountKey`` configuration.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    public static func requires<Key: AccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        precondition(
            Key.options.contains([.display, .mutable]),
            "AccountKey can only be required if its mutable and able to be displayed. Make sure that `mutable` and `display` options are set.",
            file: file,
            line: line
        )
        return .init(configuration: AccountKeyConfigurationImpl(keyPath, requirement: .required))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/collected``.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @_disfavoredOverload
    public static func collects<Key: AccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        precondition(
            Key.options.contains([.display, .mutable]),
            "AccountKey can only be collected if its mutable and able to be displayed. Make sure that `mutable` and `display` options are set.",
            file: file,
            line: line
        )
        return .init(configuration: AccountKeyConfigurationImpl(keyPath, requirement: .collected))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/supported``.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @_disfavoredOverload
    public static func supports<Key: AccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        precondition(
            Key.options.contains([.display]),
            "AccountKey can only be supported if its able to be displayed. Make sure that the `display` option is set.",
            file: file,
            line: line
        )
        return .init(configuration: AccountKeyConfigurationImpl(keyPath, requirement: .supported))
    }
    
    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/manual``.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @_disfavoredOverload
    public static func manual<Key: AccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        // just making sure we are consistent
        _ = file
        _ = line
        return .init(configuration: AccountKeyConfigurationImpl(keyPath, requirement: .manual))
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required`` as ``RequiredAccountKey`` can only be configured as required.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func collects<Key: RequiredAccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        // sadly we can't make this a compiler error. using `unavailable` makes it unavailable as an overload completely.
        requires(keyPath, file: file, line: line)
    }

    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required`` as ``RequiredAccountKey`` can only be configured as required.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func supports<Key: RequiredAccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        requires(keyPath, file: file, line: line)
    }
    
    /// Configure an ``AccountKey`` as ``AccountKeyRequirement/required`` as ``RequiredAccountKey`` can only be configured as required.
    /// - Parameters:
    ///   - keyPath: The `KeyPath` referencing the ``AccountKey``.
    ///   - file: The file where the requirement is defined.
    ///   - line: The line in which the requirement is defined.
    /// - Returns: Returns the ``AccountKey`` configuration.
    @available(*, deprecated, renamed: "requires", message: "A 'RequiredAccountKey' must always be supplied as required using requires(_:)")
    public static func manual<Key: RequiredAccountKey>(
        _ keyPath: KeyPath<AccountKeys, Key.Type>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfiguredAccountKey {
        requires(keyPath, file: file, line: line)
    }
}


extension ConfiguredAccountKey: Sendable {}
