//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct ActiveAccountServiceKey: AccountValueKey {
    public typealias Value = any AccountService
}


extension AccountDetails {
    public var accountService: ActiveAccountServiceKey.Value {
        guard let accountService = storage[ActiveAccountServiceKey.self] else {
            fatalError("""
                       The active Account Service is not present in the AccountDetails storage. \
                       This could happen, e.g., if you did not properly set up your PreviewProvider.
                       """)
        }

        return accountService
    }
}
