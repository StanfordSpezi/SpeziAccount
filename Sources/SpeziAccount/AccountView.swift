//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var account: Account

    var services: [any AccountServiceNew]

    var embeddableAccountService: (any EmbeddableAccountService)? {
        let embeddableServices = services
            .filter { $0 is any EmbeddableAccountService }

        if embeddableServices.count == 1 {
            // TODO unwrap first first and then cast?
            return embeddableServices.first as? any EmbeddableAccountService
        }

        return nil
    }

    var nonEmbeddableAccountServices: [any AccountServiceNew] {
        services
            .filter { !($0 is any EmbeddableAccountService) }
    }

    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    // TODO draw account summary if we are already signed in!
                    header

                    Spacer()

                    VStack {
                        primaryAccountServicesReplacement

                        // TODO show divider only if there is a least one account service AND identity provider!
                        servicesDivider

                        identityProviderButtons
                    }
                        .padding(.horizontal, 16)

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, 16) // TODO may use 48?
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// The Views Title and subtitle text.
    @ViewBuilder
    var header: some View {
        // TODO provide customizability with AccountViewStyle!
        Text("Welcome back!") // TODO localize
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Text("Please create an account to do whatever. You may create an account if you don't have one already!") // TODO localize!
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var primaryAccountServicesReplacement: some View {
        if services.isEmpty {
            Text("Empty!! :(((") // TODO only place hint if there are not even identity providers!
        } else if let embeddableService = embeddableAccountService {
            let embeddableViewStyle = embeddableService.viewStyle
            // TODO i can get back type erasure right?
            AnyView(embeddableViewStyle.makeEmbeddedAccountView())
            // TODO inject account service!! lol, nothing is typed!


            if !nonEmbeddableAccountServices.isEmpty {
                servicesDivider

                // TODO optimize code reuse below!
                ForEach(nonEmbeddableAccountServices.indices, id: \.self) { index in
                    let service = nonEmbeddableAccountServices[index]
                    let style = service.viewStyle

                    NavigationLink {
                        AnyView(style.makePrimaryView())
                    } label: {
                        AnyView(style.makeAccountServiceButtonLabel())
                    }
                }
            } else {
                EmptyView()
            }
        } else {
            ForEach(services.indices, id: \.self) { index in
                let service = services[index]
                let style = service.viewStyle

                NavigationLink {
                    AnyView(style.makePrimaryView())
                    // TODO inject account service!! lol, nothing is typed!
                } label: {
                    AnyView(style.makeAccountServiceButtonLabel())
                    // TODO inject account service!! lol, nothing is typed!
                    /*
                     // TODO may we provide a default implementation, or work with a optional serviceButton style?
                    AccountServiceButton {
                        Image(systemName: "ellipsis.rectangle") // TODO grab image!
                            .font(.title2)
                        Text("Account Service \(index)") // TODO grab the name!!
                    }
                    */
                }
                /*
                Button(action: {
                    print("Navigation?")
                }) {
                    Text("Account service \(index)") // TODO we need a name?
                }
                    // TODO we can't access the associated type button style!
                 */
            }
        }
    }

    /// The primary account services view.
    @ViewBuilder
    var primaryAccountServices: some View {
        // TODO mofed to default embeddded view!
        EmptyView()
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
            .padding(.horizontal, 36) // TODO depends on the global padding?
            .padding(.vertical, 16) // TODO use 16 if we expect to place two dividers!
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

                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        }

        // TODO we want to check if there is a single username/password provider and the rest are identity providers!
        //  the one need input fields! (and a secondary action!)
        //  the other need a single button
        //  => KeyPasswordBasedAuthentication[Service]
        //  => IdentityProvideBasedAuthentication[Service]
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO .environmentObject(UsernamePasswordAccountService())
        NavigationStack {
            AccountView(services: [DefaultUsernamePasswordAccountService()])
        }

        NavigationStack {
            AccountView(services: [RandomAccountService()])
        }

        NavigationStack {
            AccountView(services: [DefaultUsernamePasswordAccountService(), RandomAccountService()])
        }

        NavigationStack {
            AccountView(services: [
                DefaultUsernamePasswordAccountService(),
                RandomAccountService(),
                DefaultUsernamePasswordAccountService()
            ])
        }

        NavigationStack {
            AccountView(services: [])
        }
        // TODO .environmentObject(UsernamePasswordAccountService())
    }
}
#endif
