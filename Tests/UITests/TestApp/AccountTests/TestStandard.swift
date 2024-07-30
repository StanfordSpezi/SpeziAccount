//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SwiftUI


// mock implementation of the AccountStorageConstraint
actor TestStandard: AccountNotifyConstraint, EnvironmentAccessible {
    @MainActor
    @Observable
    final class Storage {
        var deleteNotified = false
        nonisolated init() {}
    }

    private let storage = Storage()

    @MainActor
    var deleteNotified: Bool {
        storage.deleteNotified
    }


    @MainActor
    func respondToEvent(_ event: SpeziAccount.AccountNotifications.Event) async {
        switch event {
        case .deletingAccount:
            storage.deleteNotified = true
        default:
            break
        }
    }
}
