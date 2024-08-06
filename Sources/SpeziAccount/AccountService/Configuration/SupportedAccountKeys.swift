//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The collection of `AccountKey`s that an `AccountService` is capable to storing itself.
///
/// An ``AccountService`` must set this configuration option to communicate what set of ``AccountKey`` it is
/// capable of storing.
///
/// Upon startup, `SpeziAccount` automatically verifies that the user-configured account values match what the
/// `AccountService` is capable of storing or that the user provides an ``AccountStorageProvider``
/// to handle storage of all unsupported account values.
///
/// Below is an example on how to provide a fixed set of supported account keys.
///
/// ```swift
/// let supportedKeys = AccountKeyCollection {
///     \.userId
///     \.password
///     \.name
/// }
///
/// let configuration = AccountServiceConfiguration(supportedKeys: .exactly(supportedKeys))
/// ```
public enum SupportedAccountKeys: AccountServiceConfigurationKey {
    /// The ``AccountService`` is capable of storing arbitrary account keys.
    case arbitrary
    /// The ``AccountService`` is capable of only storing a fixed set of account keys.
    case exactly(_ ofKeys: AccountKeyCollection)

    fileprivate func canStore(_ configuredValue: any AccountKeyConfiguration) -> Bool {
        switch self {
        case .arbitrary:
            return true
        case let .exactly(keys):
            guard let key = keys.first(where: { $0.key == configuredValue.key })?.key else {
                return false // we didn't find the key in the collection of supported keys
            }

            // Either it is not a `RequiredAccountKey` or it is and the requirement specifies `.required`
            // However, we automatically set a `.required` requirement for `RequiredAccountKey` so this is more of
            // a sanity/integrity check.
            return !key.isRequired || configuredValue.requirement == .required
        }
    }
}


extension AccountServiceConfiguration {
    /// Access the supported account keys of an ``AccountService``.
    public var supportedAccountKeys: SupportedAccountKeys {
        guard let value = storage[SupportedAccountKeys.self] else {
            preconditionFailure("Reached illegal state where SupportedAccountKeys configuration was never supplied!")
        }

        return value
    }

    /// Determine the set of unsupported ``AccountKey``s of this ``AccountService`` based on the global ``AccountValueConfiguration``.
    ///
    /// - Note: Access the global configuration using ``Account/configuration``.
    /// - Parameter configuration: The user-supplied account value configuration.
    /// - Returns: Returns array of ``AccountKeyConfiguration``.
    func unsupportedAccountKeys(basedOn configuration: AccountValueConfiguration) -> [any AccountKeyConfiguration] {
        let supportedValues = supportedAccountKeys

        return configuration
            .filter { configuredValue in
                !supportedValues.canStore(configuredValue)
            }
    }
}
