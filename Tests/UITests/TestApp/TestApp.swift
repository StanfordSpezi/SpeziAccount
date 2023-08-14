//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

struct EditingView: View {
    @Environment(\.editMode) private var editMode
    @State private var name = "Maria Ruiz"

    var body: some View {
        if editMode?.wrappedValue.isEditing == true {
            HStack {
                Text("Editing")
                Spacer()
                TextField("Name", text: $name)
                    .multilineTextAlignment(.trailing)
            }
        } else {
            Text(name)
        }
    }
}

struct SomeView: View {
    var body: some View {
        List {
            EditingView()
        }
            // TODO .animation(nil, value: editMode?.wrappedValue)
            .toolbar { // Assumes embedding this view in a NavigationView.
                EditButton()
            }
    }
}

@main
struct UITestsApp: App {
    @UIApplicationDelegateAdaptor(TestAppDelegate.self) var appDelegate

    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", middleName: "Michael", familyName: "Bauer"))
        .build(owner: MockUsernamePasswordAccountService())
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // TODO present AccountOverview for tests cases!
                AccountTestsView()
                    .spezi(appDelegate)
            }
        }
    }
}
