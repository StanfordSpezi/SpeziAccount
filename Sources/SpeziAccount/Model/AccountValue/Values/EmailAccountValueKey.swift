//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct EmailAccountValueKey: AccountValueKey, OptionalComputedKnowledgeSource {
    public typealias StoragePolicy = AlwaysCompute
    public typealias Value = String

    public static func compute<Repository: SharedRepository<Anchor>>(from repository: Repository) -> String? {
        if let email = repository.get(Self.self) {
            // if we have manually stored a value for this key we return it
            return email
        }

        // otherwise return the userid if its a email address
        // TODO we need to check the configuration!

        return repository[UserIdAccountValueKey.self]
    }
}


extension AccountValueKeys {
    public var email: EmailAccountValueKey.Type {
        EmailAccountValueKey.self
    }
}


extension AccountDetails {
    public var email: EmailAccountValueKey.Value? {
        get {
            // TODO we require api access to get as well!
            storage[EmailAccountValueKey.self]
        }
        set {
            storage[EmailAccountValueKey.self] = newValue
        }
    }
}
