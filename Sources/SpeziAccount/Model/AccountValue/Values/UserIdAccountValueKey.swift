//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct UserIdAccountValueKey: RequiredAccountValueKey {
    public typealias Value = String
}


extension AccountValueKeys {
    // TODO is userId update special? requires verification and stuff?
    public var userId: UserIdAccountValueKey.Type {
        UserIdAccountValueKey.self
    }
}


extension AccountValueStorageContainer {
    public var userId: UserIdAccountValueKey.Value {
        storage[UserIdAccountValueKey.self]
    }
}

// TODO one might not change the user id!
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
