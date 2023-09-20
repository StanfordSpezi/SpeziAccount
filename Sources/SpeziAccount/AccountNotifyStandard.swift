//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A `Spezi` Standard that allows to react to certain Account-based events.
public protocol AccountNotifyStandard: Standard {
    /// Notifies the Standard that the associated account was requested to be deleted by the user.
    ///
    /// Use this method to cleanup any account related data that might be associated with the account.
    func deletedAccount() async throws
}
