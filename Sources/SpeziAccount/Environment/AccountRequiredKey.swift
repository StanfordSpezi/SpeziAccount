//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountRequiredKey: EnvironmentKey {
    static let defaultValue = false
}


extension EnvironmentValues {
    /// An environment variable that indicates if an account was configured to be required for the app.
    ///
    /// Fore more information have a look at ``SwiftUICore/View/accountRequired(_:considerAnonymousAccounts:setupSheet:)``.
    public var accountRequired: Bool {
        get {
            self[AccountRequiredKey.self]
        }
        set {
            self[AccountRequiredKey.self] = newValue
        }
    }
}
