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
            .padding(.horizontal, 32)
            .padding(.vertical, 0)

        VStack {
            Button(action: {
                print("login") // TODO remove!
                Task {
                    // TODO catch stuff!
                    // TODO loading indicator
                    try! await accountService.login(key: key, password: password)
                }
            }) {
                Text("Login") // TODO localize
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 12)


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
            .padding(.horizontal, 32)
            .padding(.top)
    }
}
