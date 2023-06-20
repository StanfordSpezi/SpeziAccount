//
//  SwiftUIView.swift
//  
//
//  Created by Andreas Bauer on 17.06.23.
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var valid = false

    @Environment(\.colorScheme)
    var colorScheme

    @EnvironmentObject var account: Account
    var services: [any AccountService] {
        account.accountServices
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    Text("Welcome back!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                        .padding(.top, 30)

                    Text("Please create an account to do whatever.")
                        .multilineTextAlignment(.center)

                    Spacer()

                    VStack {
                        TextField("E-Mail Addresse or Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Spacer()
                            Button(action: {print("Forgot Password?")}) {
                                Text("Forgot Password?")
                                    .font(.caption)
                                // TODO color? .foregroundColor(.primary)
                                    .bold()
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    //.foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 0)

                    VStack {
                        Button(action: { print("login")}) {
                            Text("Login")
                                .frame(maxWidth: .infinity, minHeight: 38)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 12)


                        HStack {
                            Text("Dont' have an Account yet?")
                                .font(.footnote)
                            Button(action: {print ("singup")}) {
                                Text("Signup")
                                    .font(.footnote)
                            }
                            .padding(.horizontal, 0)
                        }

                    }
                    .padding(.horizontal, 32)
                    .padding(.top)

                    HStack {
                        VStack {
                            Divider()
                        }
                        Text("or")
                            .padding(.horizontal, 8)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        VStack {
                            Divider()
                        }
                    }
                    .padding(.horizontal, 64)
                    .padding(.vertical, 32)

                    SignInWithAppleButton { request in

                    } onCompletion: { result in

                    }
                    .frame(height: 55)
                    .padding(.horizontal, 32)
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)

                    // TODO we want to check if there is a single username/password provider and the rest are identity providers!
                    //  the one need input fields! (and a secondary action!)
                    //  the other need a single button
                    //  => KeyPasswordBasedAuthentication[Service]
                    //  => IdentityProvideBasedAuthentication[Service]

                    /*
                     if !account.accountServices.isEmpty {
                     VStack(spacing: 16) {
                     // TODO iterating over protocols foreach crashes xcode preview!
                     ForEach(services.indices, id: \.self) { index in
                     // TODO button selection based on type
                     services[index].loginButton
                     }
                     }
                     }
                     */

                    Spacer()
                    Spacer()
                    // UsernamePasswordFields(username: $username, password: $password, valid: $valid)

                }
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    @StateObject private static var account = Account(accountServices: [UsernamePasswordAccountService(), EmailPasswordAccountService()])
    @StateObject private static var emptyAccount = Account(accountServices: [])


    static var previews: some View {
        NavigationStack {
            AccountView()
        }
        //.environmentObject(UsernamePasswordAccountService())
        .environmentObject(account)

        NavigationStack {
            AccountView()
        }
        // .environmentObject(UsernamePasswordAccountService())
        .environmentObject(emptyAccount)
    }
}
