//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


public struct AccountServiceName: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static var defaultValue: AccountServiceName {
        preconditionFailure("Reached illegal state where AccountServiceName configuration was never supplied!")
    }

    public let name: LocalizedStringResource

    public init(_ name: LocalizedStringResource) {
        self.name = name
    }
}


extension AccountServiceConfiguration {
    public var name: LocalizedStringResource {
        storage[AccountServiceName.self].name
    }
}
