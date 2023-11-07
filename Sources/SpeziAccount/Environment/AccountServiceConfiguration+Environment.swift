//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// swiftlint:disable:next type_name
private struct AccountServiceConfigurationEnvironmentKey: EnvironmentKey {
    static var defaultValue: AccountServiceConfiguration {
        .init(
            name: LocalizedStringResource(
                "Default Account Service Configuration Environment Key",
                comment: "Internal use only, no need to translate."
            ),
            supportedKeys: .arbitrary
        )
    }
}


extension EnvironmentValues {
    /// Access the ``AccountServiceConfiguration`` within the context of a ``DataDisplayView`` or ``DataEntryView``.
    ///
    /// - Note: Accessing this environment value outside the view body of such view types, you will receive a unusable
    ///     mock value.
    public var accountServiceConfiguration: AccountServiceConfiguration {
        get {
            self[AccountServiceConfigurationEnvironmentKey.self]
        }
        set {
            self[AccountServiceConfigurationEnvironmentKey.self] = newValue
        }
    }
}
