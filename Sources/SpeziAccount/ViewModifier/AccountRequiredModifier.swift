//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountRequiredModifier<SetupSheet: View>: ViewModifier {
    private let enabled: Bool
    private let setupSheet: SetupSheet

    @Environment(Account.self)
    private var account: Account? // make sure that the modifier can be used when account is not configured

    @State private var presentingSheet = false


    init(enabled: Bool, @ViewBuilder setupSheet: () -> SetupSheet) {
        self.enabled = enabled
        self.setupSheet = setupSheet()
    }


    func body(content: Content) -> some View {
        content
            .onChange(of: [account?.signedIn, presentingSheet]) {
                guard enabled, let account else {
                    return
                }

                if !account.signedIn {
                    if !presentingSheet {
                        presentingSheet = true
                    }
                } else {
                    presentingSheet = false
                }
            }
            .task {
                guard enabled, let account else {
                    return
                }

                try? await Task.sleep(for: .seconds(2))
                if !account.signedIn {
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
    ///   - setupSheet: The view that is presented if no account was detected. You may present the ``AccountSetup`` view here.
    ///     This view is directly used with the standard SwiftUI sheet modifier.
    /// - Returns: The modified view.
    public func accountRequired<SetupSheet: View>(_ required: Bool = true, @ViewBuilder setupSheet: () -> SetupSheet) -> some View {
        modifier(AccountRequiredModifier(enabled: required, setupSheet: setupSheet))
    }
}
