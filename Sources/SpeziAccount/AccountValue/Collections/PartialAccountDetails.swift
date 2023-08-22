//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// Set of ``AccountValues`` that resembled ``AccountDetails`` but may be incomplete in respect to the
/// ``AccountValueConfiguration`` defined by the user.
public struct PartialAccountDetails: Sendable, AccountValues {
    public typealias Element = AnyRepositoryValue // compiler is confused otherwise

    public let storage: AccountStorage


    public init(from storage: AccountStorage) {
        self.storage = storage
    }
}
