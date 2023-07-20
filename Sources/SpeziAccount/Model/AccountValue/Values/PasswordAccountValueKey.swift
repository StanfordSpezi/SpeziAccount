//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct PasswordAccountValueKey: RequiredAccountValueKey {
    public typealias Value = String
}


extension AccountValueKeys {
    // TODO is password update special (requires existing knowledge?)
    public var password: PasswordAccountValueKey.Type {
        PasswordAccountValueKey.self
    }
}


extension SignupRequest {
    public var password: PasswordAccountValueKey.Value {
        storage[PasswordAccountValueKey.self]
    }
}
