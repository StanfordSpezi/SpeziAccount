//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO provide explicit UserNameSignupValue?
// TODO provide explicit E-MailSignup Value?

public struct UserIdAccountValueKey: AccountValueKey {
    public typealias Value = String
}

extension AccountValueStorageContainer {
    public var userId: UserIdAccountValueKey.Value {
        get {
            storage[UserIdAccountValueKey.self]
        }
    }
}

extension ModifiableAccountValueStorageContainer {
    public var userId: UserIdAccountValueKey.Value {
        get {
            storage[UserIdAccountValueKey.self]
        }
        set {
            storage[UserIdAccountValueKey.self] = newValue
        }
    }
}
