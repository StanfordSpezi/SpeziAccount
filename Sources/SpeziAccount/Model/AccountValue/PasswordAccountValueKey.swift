//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO this is probably optional? It won't be present
public struct PasswordAccountValueKey: AccountValueKey {
    public typealias Value = String
}

extension SignupRequest {
    public var password: PasswordAccountValueKey.Value {
        storage[PasswordAccountValueKey.self]
    }
}
