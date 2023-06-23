//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct DefaultKeyPasswordBasedEmbeddedView<Service: KeyPasswordBasedAccountService>: View {
    @State
    private var key: String = ""
    @State
    private var password: String = ""
    // TODO @State private var valid = false

    var accountService: Service

    init(using service: Service) {
        self.accountService = service
    }

    @MainActor
    var body: some View {
        VStack {
            VStack {
                // TODO UsernamePasswordFields(username: $username, password: $password, valid: $valid)

                // TODO localization (which is implementation dependent!)
                TextField("E-Mail Address or Username", text: $key)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Spacer()
                    NavigationLink {
                        accountService.viewStyle.makePasswordForgotView()
                    } label: {
                        Text("Forgot Password?") // TODO localize
                            .font(.caption)
                            .bold()
                            .foregroundColor(Color(uiColor: .systemGray)) // TODO color primary? secondary?
                    }
                }
            }
            .padding(.vertical, 0)

            Button(action: {
                print("login") // TODO remove!
                Task { // TODO handle task cancellation when view disappears!
                       // TODO catch stuff!
                       // TODO loading indicator (top right or login button, disable back button?)
                    try! await accountService.login(key: key, password: password)

                    // TODO diagnostic
                }
            }) {
                Text("Login") // TODO localize
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 12)
            .padding(.top)


            HStack {
                Text("Dont' have an Account yet?") // TODO localize!
                                                   // TODO navigation link
                NavigationLink {
                    accountService.viewStyle.makeSignupView()
                } label: {
                    Text("Signup") // TODO primary accent color!
                }
                // TODO .padding(.horizontal, 0)
            }
            .font(.footnote)
        }
    }
}

#if DEBUG
struct DefaultKeyPasswordBasedEmbeddedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DefaultKeyPasswordBasedEmbeddedView(using: DefaultUsernamePasswordAccountService())
        }
    }
}
#endif
