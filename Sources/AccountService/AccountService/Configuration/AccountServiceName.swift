//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


/// The localized name of an ``AccountService``.
///
/// UI components may use this configuration to textually refer to an ``AccountService``.
///
/// Access the configuration via the ``AccountServiceConfiguration/name`` property.
public struct AccountServiceName: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static var defaultValue: AccountServiceName {
        preconditionFailure("Reached illegal state where AccountServiceName configuration was never supplied!")
    }

    /// The localized name of the ``AccountService``.
    public let name: LocalizedStringResource


    /// Initialize a new `AccountServiceName`.
    ///
    /// This initializer is internal-access only, as it is required by the ``AccountServiceConfiguration`` initializer.
    /// - Parameter name: The localized name of the ``AccountService``.
    init(_ name: LocalizedStringResource) {
        self.name = name
    }
}


extension AccountServiceConfiguration {
    /// Access the localized name of an ``AccountService``.
    public var name: LocalizedStringResource {
        storage[AccountServiceName.self].name
    }
}
