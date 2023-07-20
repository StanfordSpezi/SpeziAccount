//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate

    @EnvironmentObject
    var account: Account
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AccountTestsView()
                    .spezi(appDelegate)
                    .onAppear {
                        account.details?.update(\.genderIdentity, value: .female)
                    }
            }
        }
    }
}
