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

    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AccountOverview()
                    .environmentObject(Account(building: Self.details, active: MockUsernamePasswordAccountService()))
                // TODO present AccountOverview for tests cases!
                // AccountTestsView()
                //    .spezi(appDelegate)
            }
        }
    }
}
