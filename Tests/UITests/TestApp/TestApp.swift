//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKitAccount
import SwiftUI


@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AccountTestsView()
                    .navigationTitle("CardinalKit Account")
                    .cardinalKit(appDelegate)
            }
        }
    }
}
