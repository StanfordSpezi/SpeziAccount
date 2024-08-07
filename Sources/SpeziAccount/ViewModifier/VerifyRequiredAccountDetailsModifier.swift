//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct FollowUpSession: Identifiable {
    var id: String {
        details.userId
    }

    let details: AccountDetails
    let requiredKeys: [any AccountKey.Type]
}


struct VerifyRequiredAccountDetailsModifier: ViewModifier {
    @Environment(Account.self)
    private var account

    @SceneStorage("edu.stanford.spezi-account.startup-account-check")
    private var verifiedAccount = false
    @State private var followUpSession: FollowUpSession?


    init() {}


    func body(content: Content) -> some View {
        content
            .sheet(item: $followUpSession) { session in
                NavigationStack {
                    FollowUpInfoSheet(keys: session.requiredKeys)
                }
            }
            .onChange(of: account.signedIn, initial: true) {
                guard let details = account.details, !verifiedAccount else {
                    return
                }

                verifiedAccount = true
                let missingKeys = account.configuration.missingRequiredKeys(for: details)

                if !missingKeys.isEmpty {
                    followUpSession = FollowUpSession(details: details, requiredKeys: missingKeys)
                }
            }
            .task {
                guard !verifiedAccount else {
                    return
                }

                try? await Task.sleep(for: .seconds(5)) // we let the initial account setup take up to 5s
                verifiedAccount = true
            }
    }
}


extension View {
    /// Ensure that all user accounts in your app are up to date with your SpeziAccount configuration upon startup.
    ///
    /// Within your ``AccountConfiguration`` you define your app-global ``AccountValueConfiguration`` that defines
    /// what ``AccountKey`` are required and collected at signup. You can use this modifier to collect additional information
    /// form existing users, should your configuration of **required** account keys change between one of your releases.
    ///
    /// This check is performed only upon app startup for the currently associated user account. Otherwise, this check is automatically done
    /// upon login with the ``AccountSetup`` view.
    ///
    /// - Parameter verify: Flag indicating if this verification check is turned on.
    /// - Returns: The modified view.
    @ViewBuilder
    public func verifyRequiredAccountDetails(_ verify: Bool = true) -> some View { // TODO: new name!
        if verify {
            modifier(VerifyRequiredAccountDetailsModifier())
        } else {
            self
        }
    }
}
