//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


class SignupSubmitHooks {
    var storage: [ObjectIdentifier: () -> DataValidationResult] = [:]

    func register<Key: AccountValueKey>(_ key: Key.Type, hook: @escaping () -> DataValidationResult) {
        storage[key.id] = hook
    }
}
