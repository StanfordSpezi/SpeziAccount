//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


public struct ActiveAccountServiceKey: KnowledgeSource {
    public typealias Anchor = AccountAnchor
    // TODO this should just be a KnowledgeSource!
    public typealias Value = any AccountService
    // TODO sendable and eqautable conformance for any AccountService?
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
