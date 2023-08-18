//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public enum SupportedAccountValues: AccountServiceConfigurationKey {
    case arbitrary
    case exactly(ofKeys: AccountKeyCollection)

    func canStore(_ configuredValue: AnyAccountValueConfigurationEntry) -> Bool {
        switch self {
        case .arbitrary:
            return true
        case let .exactly(keys):
            guard let key = keys.first(where: { $0 == configuredValue.anyKey }) else {
                return false // we didn't find the key in the collection of supported keys
            }

            // Wither the it is not a `RequiredAccountValueKey` or it is and the requirement specifies `.required`
            // However, we automatically set a `.required` requirement for `RequiredAccountValueKey` so this is more of
            // a sanity/integrity check.
            return !key.isRequired || configuredValue.requirement == .required
        }
    }
}


extension AccountServiceConfiguration {
    /// Access the supported account values of an ``AccountService``.
    public var supportedAccountValues: SupportedAccountValues {
        // TODO do that with all of the others? more compact for code coverage?
        guard let value = storage[SupportedAccountValues.self] else {
            preconditionFailure("Reached illegal state where SupportedAccountValues configuration was never supplied!")
        }

        return value
    }
}
