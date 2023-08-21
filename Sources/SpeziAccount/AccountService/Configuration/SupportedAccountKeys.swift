//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public enum SupportedAccountKeys: AccountServiceConfigurationKey {
    case arbitrary
    case exactly(ofKeys: AccountKeyCollection)

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
        // TODO do that with all of the others? more compact for code coverage?
        guard let value = storage[SupportedAccountKeys.self] else {
            preconditionFailure("Reached illegal state where SupportedAccountKeys configuration was never supplied!")
        }

        return value
    }

    public func unsupportedAccountKeys(basedOn configuration: AccountValueConfiguration) -> [any AccountKeyConfiguration] {
        let supportedValues = supportedAccountKeys

        return configuration
            .filter { configuredValue in
                !supportedValues.canStore(configuredValue)
            }
    }
}
