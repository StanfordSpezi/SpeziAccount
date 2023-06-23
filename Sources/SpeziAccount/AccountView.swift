//
//  SwiftUIView.swift
//  
//
//  Created by Andreas Bauer on 17.06.23.
//

import AuthenticationServices
import SwiftUI

struct AccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var valid = false

    @EnvironmentObject var account: Account

    var services: [any AccountServiceNew] {
        [] // TODO make some mockups
    }

    var embeddableAccountService: (any EmbeddableAccountService)? {
        let embeddableServices = services
            .filter { $0 is any EmbeddableAccountService }

        if embeddableServices.count == 1 {
            // TODO unwrap first first and then cast?
            return embeddableServices.first as? any EmbeddableAccountService
        }

        return nil
    }

    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header

                    Spacer()

                    primaryAccountServicesReplacement

                    servicesDivider

                    identityProviderButtons

                    Spacer()
                    Spacer()
                }
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// The Views Title and subtitle text.
    @ViewBuilder
    var header: some View {
        Text("Welcome back!")
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("Please create an account to do whatever.")
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var primaryAccountServicesReplacement: some View {
        if services.isEmpty {
            Text("Empty!! :(((")
        } else if let embeddableService = embeddableAccountService {
            // TODO i can get back type erasure right?
            AnyView(embeddableService.makeEmbeddedView())
        } else {
            ForEach(services.indices, id: \.self) { index in
                let service = services[index]
                Button(action: {
                    print("Navigation?")
                }) {
                    Text("Account service \(index)") // TODO we need a name?
                }
                    // TODO we can't access the associated type button style!
            }
        }
    }

    /// The primary account services view.
    @ViewBuilder
    var primaryAccountServices: some View {
        VStack {
            // TODO UsernamePasswordFields(username: $username, password: $password, valid: $valid)
            TextField("E-Mail Address or Username", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button(action: {
                    print("Forgot Password?")
                }) {
                    Text("Forgot Password?")
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
                print("login")
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 12)


            HStack {
                Text("Dont' have an Account yet?")
                Button(action: {
                    print("signup")
                }) {
                    Text("Signup")
                }
                    // TODO .padding(.horizontal, 0)
            }
                .font(.footnote)
        }
            .padding(.horizontal, 32)
            .padding(.top)
    }

    // The "or" divier between primiary account services and the third-party identity providers
    @ViewBuilder
    var servicesDivider: some View {
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
    }

    /// VStack of buttons provided by the identity providers
    @ViewBuilder
    var identityProviderButtons: some View {
        VStack {
            SignInWithAppleButton { request in
                print("Sign in request!")
            } onCompletion: { result in
                print("sing in completed")
            }
                .frame(height: 55)
                .padding(.horizontal, 32)

                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        }

        // TODO we want to check if there is a single username/password provider and the rest are identity providers!
        //  the one need input fields! (and a secondary action!)
        //  the other need a single button
        //  => KeyPasswordBasedAuthentication[Service]
        //  => IdentityProvideBasedAuthentication[Service]
    }
}

struct AccountView_Previews: PreviewProvider {
    @StateObject private static var account = Account(accountServices: [UsernamePasswordAccountService(), EmailPasswordAccountService()])
    @StateObject private static var emptyAccount = Account(accountServices: [])


    static var previews: some View {
        NavigationStack {
            AccountView()
        }
        // TODO .environmentObject(UsernamePasswordAccountService())
        .environmentObject(account)
        NavigationStack {
            AccountView()
        }
        // TODO .environmentObject(UsernamePasswordAccountService())
        .environmentObject(emptyAccount)
    }
}
