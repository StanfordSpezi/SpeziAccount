//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO make everything public!

// TODO app needs access to the "primary?"/signed in (we don't support multi account sign ins!) account service!
//  -> logout functionality
//  -> AccountSummary
//  -> allows for non-account-service-specific app implementations (e.g., easily switch for testing) => otherwise cast!

protocol AccountServiceNew {
    associatedtype ViewStyle: AccountSetupViewStyle

    // TODO provide access to `Account` to communicate changes back to the App

    var viewStyle: ViewStyle { get }

    func logout() async throws
}
