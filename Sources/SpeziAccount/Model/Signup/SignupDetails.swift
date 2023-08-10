//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct SignupDetails: Sendable, AccountValueStorageContainer {
    public typealias Builder = AccountValueStorageBuilder<Self>

    public let storage: AccountValueStorage

    init(storage: AccountValueStorage) {
        self.storage = storage
    }
}


extension AccountValueStorageBuilder where Container == SignupDetails {
    public func build(
        checking requirements: AccountValueRequirements? = nil
    ) throws -> Container {
        let details = SignupDetails(storage: self.storage)

        if let requirements {
            try requirements.validateRequirements(in: details)
        }

        return details
    }
}
