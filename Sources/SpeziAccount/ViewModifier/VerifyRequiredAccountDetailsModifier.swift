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
    @Environment(Account.self) private var account

    @SceneStorage("edu.stanford.spezi-account.startup-account-check") private var verifiedAccount = false
    @State private var followUpSession: FollowUpSession?


    init() {
    }


    func body(content: Content) -> some View {
        content
            .sheet(item: $followUpSession) { session in
                FollowUpInfoSheet(details: session.details, requiredKeys: session.requiredKeys)
            }
            .task {
                guard !verifiedAccount else {
                    return
                }

                try? await Task.sleep(for: .milliseconds(500))
                verifiedAccount = true

                if let details = account.details {
                    let missingKeys = account.configuration.missingRequiredKeys(for: details)

                    if !missingKeys.isEmpty {
                        followUpSession = FollowUpSession(details: details, requiredKeys: missingKeys)
                    }
                }
            }
    }
}


extension View {
    /// Used this modifier to ensure that all user accounts in your app are up to date with your
    /// SpeziAccount configuration.
    ///
    /// Within your ``AccountConfiguration`` you define your app-global ``AccountValueConfiguration`` that defines
    /// what ``AccountKey`` are required and collected at signup. You can use this modifier to collect additional information
    /// form existing users, should your configuration of **required** account keys change between one of your releases.
    ///
    /// - Parameter verify: Flag indicating if this verification check is turned on.
    /// - Returns: The modified view.
    @ViewBuilder
    public func verifyRequiredAccountDetails(_ verify: Bool = true) -> some View {
        if verify {
            modifier(VerifyRequiredAccountDetailsModifier())
        } else {
            self
        }
    }
}
