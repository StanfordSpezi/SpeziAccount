//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation


extension AccountDetails {
    private struct IsNewUserKey: KnowledgeSource {
        typealias Anchor = AccountAnchor
        typealias Value = Bool
    }

    /// Determine if the user was freshly created.
    ///
    /// If this flag is set to `true`, the ``AccountSetup`` view will render a additional information sheet not only for
    /// ``AccountKeyRequirement/required``, but also for ``AccountKeyRequirement/collected`` account values.
    /// This is primarily helpful for identity providers. You might not want to set this flag
    /// if you using the builtin ``SignupForm``!
    public var isNewUser: Bool { // TODO: update these docs should the behavior change?
        get {
            self[IsNewUserKey.self] ?? false
        }
        set {
            self[IsNewUserKey.self] = newValue
        }
    }
}
