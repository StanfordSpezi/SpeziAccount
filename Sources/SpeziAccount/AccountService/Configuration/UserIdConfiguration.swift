//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct UserIdConfiguration: AccountServiceConfigurationKey, DefaultProvidingKnowledgeSource {
    public static var defaultValue: UserIdConfiguration {
        UserIdConfiguration(type: .emailAddress, fieldType: .emailAddress)
    }

    public let idType: UserIdType
    public let fieldType: FieldType

    public init(type: UserIdType, fieldType: FieldType) {
        self.idType = type
        self.fieldType = fieldType
    }
}


extension AccountServiceConfiguration {
    public var userIdConfiguration: UserIdConfiguration {
        storage[UserIdConfiguration.self]
    }
}
