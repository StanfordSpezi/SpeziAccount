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


@MainActor
struct AccountTestsView: View {
    @Environment(\.features) var features
    
    @Environment(Account.self) var account: Account
    @Environment(TestStandard.self) var standard

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
                Button("Account Logout", role: .destructive) {
                    Task {
                        try? await account.details?.accountService.logout()
                    }
                }
                    .disabled(!account.signedIn)
            }
                .navigationTitle("Spezi Account")
                .sheet(isPresented: $showSetup) {
                    setupSheet()
                }
                .sheet(isPresented: $showOverview) {
                    overviewSheet
                }
        }
            .accountRequired(features.accountRequiredModifier) {
                setupSheet(closeable: false)
            }
            .verifyRequiredAccountDetails(features.verifyRequiredDetails)
    }

    @ViewBuilder var overviewSheet: some View {
        NavigationStack {
            AccountOverview(isEditing: $isEditing) {
                NavigationLink {
                    Text(verbatim: "")
                        .navigationTitle(Text(verbatim: "Package Dependencies"))
                } label: {
                    Text(verbatim: "License Information")
                }
            }
        }
        .toolbar {
            toolbar(closing: $showOverview)
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
                Text(verbatim: "Got notified about deletion!")
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


    @ViewBuilder
    func setupSheet(closeable: Bool = true) -> some View {
        NavigationStack {
            AccountSetup { _ in
                showSetup = false
            } continue: {
                finishButton
            }
                .toolbar {
                    if closeable {
                        toolbar(closing: $showSetup)
                    }
                }
        }
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
            .environment(Account(TestAccountService(.emailAddress)))

        AccountTestsView()
            .environment(Account(building: details, active: TestAccountService(.emailAddress)))

        AccountTestsView()
            .environment(Account())
    }
}
#endif
