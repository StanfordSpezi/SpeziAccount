//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AuthenticationServices
import SpeziViews
import SwiftUI


public enum Constants { // TODO rename!
    static let outerHorizontalPadding: CGFloat = 16
    static let innerHorizontalPadding: CGFloat = 16
    static let maxFrameWidth: CGFloat = 450
}


/// A view which provides the default title and subtitle text.
public struct AccountSetupDefaultHeader: View { // TODO move
    @EnvironmentObject
    private var account: Account

    public var body: some View {
        // TODO provide customizable with AccountViewStyle!
        Text("ACCOUNT_WELCOME".localized(.module))
            .font(.largeTitle)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .padding(.top, 30)

        Group {
            if !account.signedIn {
                Text("ACCOUNT_WELCOME_SUBTITLE".localized(.module))
            } else {
                Text("ACCOUNT_WELCOME_SIGNED_IN_SUBTITLE".localized(.module))
            }
        }
        .multilineTextAlignment(.center)
    }

    public init() {}
}

// TODO review accessibility!


/// The central `SpeziAccount` view to setup a user account.
///
/// TODO docs: drop ``AccountService`` and ``IdentityProvider`` and other stuff
public struct AccountSetup<Header: View>: View { // TODO docs!
    private let header: Header

    @EnvironmentObject var account: Account
    @Environment(\.colorScheme)
    var colorScheme

    private var services: [any AccountService] {
        account.registeredAccountServices
    }

    private var identityProviders: [String] {
        ["Apple"] // TODO query from account and model them
    }

    private var embeddableAccountService: (any EmbeddableAccountService)? {
        let embeddableServices = services
            .filter { $0 is any EmbeddableAccountService }

        if embeddableServices.count == 1 {
            return embeddableServices.first as? any EmbeddableAccountService
        }

        return nil
    }

    private var nonEmbeddableAccountServices: [any AccountService] {
        services
            .filter { !($0 is any EmbeddableAccountService) }
    }

    private var documentationUrl: URL {
        // we may move to a #URL macro once Swift 5.9 is shipping
        guard let docsUrl = URL(string: "https://swiftpackageindex.com/stanfordspezi/speziaccount/documentation/speziaccount/createanaccountservice") else {
            fatalError("Failed to construct SpeziAccount Documentation URL. Please review URL syntax!")
        }

        return docsUrl
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header

                    Spacer()

                    if let account = account.details {
                        displayAccount(details: account)
                    } else {
                        accountSetupView
                    }

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, Constants.outerHorizontalPadding)
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var accountSetupView: some View {
        if services.isEmpty && identityProviders.isEmpty {
            emptyServicesView
        } else {
            VStack {
                accountServicesSection

                if !services.isEmpty && !identityProviders.isEmpty {
                    servicesDivider
                }

                identityProviderSection
            }
                .padding(.horizontal, Constants.innerHorizontalPadding)
                .frame(maxWidth: Constants.maxFrameWidth) // landscape optimizations
            // TODO for large dynamic size it would make sense to scale it though?
        }
    }

    @ViewBuilder
    private var emptyServicesView: some View {
        Text("MISSING_ACCOUNT_SERVICES".localized(.module))
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)

        Button(action: {
            UIApplication.shared.open(documentationUrl)
        }) {
            Text("OPEN_DOCUMENTATION".localized(.module))
        }
            .padding()
    }

    @ViewBuilder
    private var accountServicesSection: some View {
        if let embeddableService = embeddableAccountService {
            let embeddableViewStyle = embeddableService.viewStyle
            AnyView(embeddableViewStyle.makeEmbeddedAccountView())

            if !nonEmbeddableAccountServices.isEmpty {
                servicesDivider

                buildAccountServiceList(nonEmbeddableAccountServices)
            } else {
                EmptyView()
            }
        } else {
            buildAccountServiceList(services)
        }
    }

    // The "or" divider between primary account services and the third-party identity providers
    @ViewBuilder
    private var servicesDivider: some View {
        HStack {
            VStack {
                Divider()
            }
            Text("OR", bundle: .module)
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

    /// Buttons provided by the identity providers
    @ViewBuilder
    private var identityProviderSection: some View {
        VStack {
            ForEach(identityProviders.indices, id: \.self) { index in
                SignInWithAppleButton { request in
                    print("Sign in request!")
                } onCompletion: { result in
                    print("sing in completed")
                }
                .frame(height: 55)
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            }
        }
    }


    // TODO docs
    public init(@ViewBuilder _ header: () -> Header = { AccountSetupDefaultHeader() }) {
        self.header = header()
    }


    private func buildAccountServiceList(_ accountServices: [any AccountService]) -> some View {
        // We use indices here as the preview provider has some issues with ForEach and a `any` existential.
        // As the array doesn't change this is completely fine and the index is a stable identifier.
        ForEach(accountServices.indices, id: \.self) { index in
            let service = accountServices[index]
            let style = service.viewStyle

            NavigationLink {
                AnyView(style.makePrimaryView())
            } label: {
                style.makeAnyAccountServiceButtonLabel()
            }
        }
    }

    func displayAccount(details: AccountDetails) -> some View {
        let service = details.accountService

        // TODO someone needs to place the Continue button?

        return AnyView(service.viewStyle.makeAccountSummary(account: details))
    }
}


extension AccountSetupViewStyle {
    fileprivate func makeAnyAccountServiceButtonLabel() -> AnyView {
        // as the `AccountSetup` only has a type-erased view on the `AccountSetupViewStyle`
        // we can't, because of the default implementation, create the AnyView inline.
        AnyView(self.makeAccountServiceButtonLabel())
    }
}


#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var accountServicePermutations: [[any AccountService]] = {
       [
           [MockUsernamePasswordAccountService()],
           [MockSimpleAccountService()],
           [MockUsernamePasswordAccountService(), MockSimpleAccountService()],
           [
                // TODO this isn't properly displayed in the preview! (double primary view?)
               MockUsernamePasswordAccountService(),
               MockSimpleAccountService(),
               MockUsernamePasswordAccountService()
           ],
           []
       ]
    }()

    static let detailsBuilder = AccountDetails.Builder()
        .add(\.userId, value: "andi.bauer@tum.de")
        .add(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))

    static var previews: some View {
        ForEach(accountServicePermutations.indices, id: \.self) { index in
            NavigationStack {
                AccountSetup()
            }
                .environmentObject(Account(services: accountServicePermutations[index]))
        }

        NavigationStack {
            AccountSetup()
        }
        .environmentObject(Account(building: detailsBuilder, active: MockUsernamePasswordAccountService()))
    }
}
#endif
