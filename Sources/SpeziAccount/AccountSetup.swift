//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum Constants { // TODO rename and move!
    static let outerHorizontalPadding: CGFloat = 16
    static let innerHorizontalPadding: CGFloat = 16
    static let maxFrameWidth: CGFloat = 450
}


/// The central ``SpeziAccount`` view to login into or signup for a user account.
///
/// - Note: This view assumes to have a ``Account`` object in its environment. An ``Account`` object is
///     automatically injected into your view hierarchy by using the ``AccountConfiguration``.
///
/// TODO docs: drop ``AccountService`` and ``IdentityProvider`` and other stuff
public struct AccountSetup<Header: View, Continue: View>: View { // TODO docs!
    private let header: Header
    private let continueButton: Continue

    @EnvironmentObject var account: Account

    private var services: [any AccountService] {
        account.registeredAccountServices
    }

    private var identityProviders: [any IdentityProvider] {
        account.registeredIdentityProviders
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    header

                    Spacer()

                    if let details = account.details {
                        ExistingAccountView(details: details) {
                            continueButton
                        }
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

    @ViewBuilder private var accountSetupView: some View {
        if services.isEmpty && identityProviders.isEmpty {
            EmptyServicesWarning()
        } else {
            VStack {
                AccountServicesSection(services: services)

                if !services.isEmpty && !identityProviders.isEmpty {
                    ServicesDivider()
                }

                IdentityProviderSection(providers: identityProviders)
            }
                .padding(.horizontal, Constants.innerHorizontalPadding)
                .frame(maxWidth: Constants.maxFrameWidth) // landscape optimizations
                .dynamicTypeSize(.medium ... .xxxLarge) // ui doesn't make sense on size larger than .xxxLarge
        }
    }

    public init(
        @ViewBuilder `continue`: () -> Continue = { EmptyView() }
    ) where Header == DefaultAccountSetupHeader {
        self.init(continue: `continue`, header: { DefaultAccountSetupHeader() })
    }


    public init(
        @ViewBuilder `continue`: () -> Continue = { EmptyView() },
        @ViewBuilder header: () -> Header
    ) {
        self.header = header()
        self.continueButton = `continue`()
    }
}


#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var accountServicePermutations: [[any AccountService]] = {
       [
           [MockUserIdPasswordAccountService()],
           [MockSimpleAccountService()],
           [MockUserIdPasswordAccountService(), MockSimpleAccountService()],
           [
               MockUserIdPasswordAccountService(),
               MockSimpleAccountService(),
               MockUserIdPasswordAccountService()
           ],
           []
       ]
    }()

    static let detailsBuilder = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))

    @MainActor static var previews: some View {
        ForEach(accountServicePermutations.indices, id: \.self) { index in
            NavigationStack {
                AccountSetup()
            }
                .environmentObject(Account(services: accountServicePermutations[index], identityProviders: [MockSignInWithAppleProvider()]))
        }

        NavigationStack {
            AccountSetup()
        }
            .environmentObject(Account(building: detailsBuilder, active: MockUserIdPasswordAccountService()))

        NavigationStack {
            AccountSetup {
                Button(action: {
                    print("Continue")
                }, label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, minHeight: 38)
                })
                    .buttonStyle(.borderedProminent)
            }
        }
            .environmentObject(Account(building: detailsBuilder, active: MockUserIdPasswordAccountService()))
    }
}
#endif
