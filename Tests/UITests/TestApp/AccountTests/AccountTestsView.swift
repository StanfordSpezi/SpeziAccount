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
    // @EnvironmentObject var account: Account
    // @EnvironmentObject var userNo: User // TODO removed
    // @State var showLogin = false
    // @State var showSignUp = false
    // TODO show different configurations (e.g. multiple account services vs ??)
    
    var body: some View {
        AccountSetup()
            // TODO .navigationTitle("Spezi Account")
        /*
        List {
            if account.signedIn {
                HStack {
                    UserProfileView(name: user.name)
                        .frame(height: 30)
                    Text(user.username ?? user.name.formatted())
                }
            }
            Button("Login") {
                showLogin.toggle()
            }
            Button("SignUp") {
                showSignUp.toggle()
            }
        }
            .sheet(isPresented: $showLogin) {
                NavigationStack {
                    Login()
                }
            }
            .sheet(isPresented: $showSignUp) {
                NavigationStack {
                    SignUp()
                }
            }
            .onChange(of: account.signedIn) { signedIn in
                if signedIn {
                    showLogin = false
                    showSignUp = false
                }
            }
         */
    }
}


#if DEBUG
struct AccountTestsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AccountTestsView()
        }
            .environmentObject(Account(services: [TestUsernamePasswordAccountService()]))

        NavigationStack {
            AccountTestsView()
        }
            .environmentObject(Account())
    }
}
#endif
