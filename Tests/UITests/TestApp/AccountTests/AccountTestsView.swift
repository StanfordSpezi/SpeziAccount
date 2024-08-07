//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport)
import SpeziAccount
import SpeziViews
import SwiftUI


@MainActor
struct AccountTestsView: View {
    @Environment(\.features)
    private var features
    @Environment(InMemoryAccountService.self)
    private var service

    @Environment(Account.self)
    private var account
    @Environment(TestStandard.self)
    private var standard

    @State private var showSetup = false
    @State private var showOverview = false
    @State private var accountIdFromAnonymousUser: String?

    
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
                        try? await account.accountService.logout()
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
            .task {
                var details: AccountDetails = .defaultDetails
                if features.noName {
                    details.remove(AccountKeys.name)
                }

                do {
                    switch features.credentials {
                    case .create:
                        try await service.signUp(with: details)
                        try await service.logout()
                    case .createAndSignIn:
                        try await service.signUp(with: details)
                    case .disabled:
                        break
                    }
                } catch {
                    print("Failed to prepare default credentials: \(error)")
                }
            }
    }

    @ViewBuilder var overviewSheet: some View {
        NavigationStack {
            AccountOverview(close: .showCloseButton) {
                NavigationLink {
                    Text(verbatim: "")
                        .navigationTitle(Text(verbatim: "Package Dependencies"))
                } label: {
                    Text(verbatim: "License Information")
                }
            }
        }
    }

    @ViewBuilder var header: some View {
        if let details = account.details {
            Section("Account Details") {
                ListRow("User Id") {
                    if details.isAnonymous {
                        Text(verbatim: "Anonymous")
                            .onAppear {
                                accountIdFromAnonymousUser = details.accountId
                            }
                    } else {
                        Text(details.userId)
                    }
                }
                if let accountIdFromAnonymousUser {
                    ListRow("Account Id") {
                        if details.accountId == accountIdFromAnonymousUser {
                            Text(verbatim: "Stable")
                                .foregroundStyle(.green)
                        } else {
                            Text(verbatim: "Changed")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        let standard = standard
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

    func toolbar(closing flag: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                flag.wrappedValue = false
            }
        }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return AccountTestsView()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.genderIdentity = .male

    return AccountTestsView()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    AccountTestsView()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
