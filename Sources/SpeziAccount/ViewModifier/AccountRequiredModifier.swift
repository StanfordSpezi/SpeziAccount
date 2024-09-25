//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI


private let logger = Logger(subsystem: "edu.stanford.sepzi.SepziAccount", category: "AccountRequiredModifier")


struct AccountRequiredModifier<SetupSheet: View>: ViewModifier {
    private let enabled: Bool
    private let accountSetupIsComplete: (AccountDetails) -> Bool
    private let setupSheet: SetupSheet

    @Environment(Account.self)
    private var account: Account? // make sure that the modifier can be used when account is not configured

    @State private var presentingSheet = false

    @MainActor private var shouldPresentSheet: Bool {
        guard let account, enabled else {
            return false
        }

        guard let details = account.details else {
            return true // not signedIn
        }

        // we present the sheet if the account is not valid (yet)
        return !accountSetupIsComplete(details)
    }


    init(
        enabled: Bool,
        accountSetupIsComplete: @escaping (AccountDetails) -> Bool,
        @ViewBuilder setupSheet: () -> SetupSheet
    ) {
        self.enabled = enabled
        self.accountSetupIsComplete = accountSetupIsComplete
        self.setupSheet = setupSheet()
    }


    func body(content: Content) -> some View {
        content
            .onChange(of: [shouldPresentSheet, presentingSheet]) {
                if shouldPresentSheet != presentingSheet {
                    presentingSheet = shouldPresentSheet
                }
            }
            .task {
                guard enabled else {
                    return
                }

                guard account != nil else {
                    logger.error("""
                                 accountRequired(_:isValid:setupSheet:) modifier was enabled but `Account` was not configured. \
                                 Make sure to include the `AccountConfiguration` the configuration section of your App delegate.
                                 """)
                    return
                }

                try? await Task.sleep(for: .seconds(2))
                if shouldPresentSheet {
                    presentingSheet = true
                }
            }
            .sheet(isPresented: $presentingSheet) {
                setupSheet
                    .interactiveDismissDisabled(true)
            }
            .environment(\.accountRequired, enabled)
    }
}


extension View {
    /// Use this modifier to ensure that there is always an associated account in your app.
    ///
    /// If account requirement is set, this modifier will automatically pop open an account setup sheet if
    /// it is detected that the associated user account was removed.
    ///
    /// - Note: This modifier injects the ``SwiftUI/EnvironmentValues/accountRequired`` property depending on the `required` argument.
    ///
    /// - Parameters:
    ///   - required: The flag indicating if an account is required at all times.
    ///   - considerAnonymousAccounts: Anonymous accounts are considered full accounts and fulfill the account requirements. See ``AccountDetails/isAnonymous``.
    ///   - setupSheet: The view that is presented if no account was detected. You may present the ``AccountSetup`` view here.
    ///     This view is directly used with the standard SwiftUI sheet modifier.
    /// - Returns: The modified view.
    public func accountRequired<SetupSheet: View>(
        _ required: Bool = true,
        accountSetupIsComplete: @escaping (AccountDetails) -> Bool = { !$0.isAnonymous },
        @ViewBuilder setupSheet: () -> SetupSheet
    ) -> some View {
        modifier(
            AccountRequiredModifier(
                enabled: required,
                accountSetupIsComplete: accountSetupIsComplete,
                setupSheet: setupSheet
            )
        )
    }
}
