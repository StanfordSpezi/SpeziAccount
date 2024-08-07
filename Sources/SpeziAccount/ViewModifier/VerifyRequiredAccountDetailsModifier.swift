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
    private struct DetailsState: Equatable {
        let signedIn: Bool
        let isIncomplete: Bool? // swiftlint:disable:this discouraged_optional_boolean
    }
    private let enabled: Bool

    @Environment(Account.self)
    private var account

    @SceneStorage("edu.stanford.spezi-account.startup-account-check")
    private var verifiedAccount = false
    @State private var followUpSession: FollowUpSession?

    @MainActor private var state: DetailsState {
        DetailsState(signedIn: account.signedIn, isIncomplete: account.details?.isIncomplete)
    }

    nonisolated init(enabled: Bool = true) {
        self.enabled = enabled
    }


    func body(content: Content) -> some View {
        content
            .sheet(item: $followUpSession) { session in
                NavigationStack {
                    FollowUpInfoSheet(keys: session.requiredKeys)
                }
            }
            .onChange(of: state, initial: true) {
                guard enabled else {
                    return
                }

                guard let details = account.details, !details.isIncomplete else {
                    followUpSession = nil
                    return
                }

                guard !verifiedAccount else {
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
