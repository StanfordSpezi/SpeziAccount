//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SpeziViews
import SwiftUI


struct AccountTestsView: View {
    @Environment(\.features) var features

    @EnvironmentObject var account: Account
    @EnvironmentObject var standard: TestStandard

    @State var showSetup = false
    @State var showOverview = false
    @State var isEditing = false

    
    var body: some View {
        NavigationStack {
            List {
                header
                Button("Account Setup") {
                    showSetup = true
                }
                Button("Account Overview") {
                    showOverview = true
                }
            }
                .navigationTitle("Spezi Account")
                .sheet(isPresented: $showSetup) {
                    NavigationStack {
                        AccountSetup {
                            finishButton
                        }
                            .toolbar {
                                toolbar(closing: $showSetup)
                            }
                    }
                }
                .sheet(isPresented: $showOverview) {
                    NavigationStack {
                        AccountOverview(isEditing: $isEditing)
                            .toolbar {
                                toolbar(closing: $showOverview)
                            }
                    }
                }
                .onChange(of: account.signedIn) { newValue in
                    if newValue {
                        showSetup = false
                    }
                }
        }
    }

    @ViewBuilder var header: some View {
        if let details = account.details {
            Section("Account Details") {
                Text(details.userId)
            }
        }
        if standard.deleteNotified {
            Section {
                Text("Got notified about deletion!")
            }
        }
    }


    @ViewBuilder var finishButton: some View {
        Button(action: {
            showSetup = false
        }, label: {
            Text("Finish")
                .frame(maxWidth: .infinity, minHeight: 38)
        })
            .buttonStyle(.borderedProminent)
    }


    @ToolbarContentBuilder
    func toolbar(closing flag: Binding<Bool>) -> some ToolbarContent {
        if !isEditing {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    flag.wrappedValue = false
                }
            }
        }
    }
}


#if DEBUG
struct AccountTestsView_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))
        .set(\.genderIdentity, value: .male)

    static var previews: some View {
        AccountTestsView()
            .environmentObject(Account(TestAccountService(.emailAddress)))

        AccountTestsView()
            .environmentObject(Account(building: details, active: TestAccountService(.emailAddress)))

        AccountTestsView()
            .environmentObject(Account())
    }
}
#endif
