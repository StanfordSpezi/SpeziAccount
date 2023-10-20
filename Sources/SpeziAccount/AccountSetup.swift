//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public enum _AccountSetupState: EnvironmentKey { // swiftlint:disable:this type_name
    case generic
    case setupShown
    case requiringAdditionalInfo
    case loadingExistingAccount

    public static var defaultValue: _AccountSetupState = .generic
}

/// The essential ``SpeziAccount`` view to login into or signup for a user account.
///
/// This view handles account setup for a user. The user can choose from all configured ``AccountService`` and
/// ``IdentityProvider`` instances to setup an active user account. They might create a new account with a given
/// ``AccountService`` or log into an existing one.
///
/// This view relies on an ``Account`` object in its environment. This is done automatically by providing a
/// ``AccountConfiguration`` in the configuration section of your `Spezi` app delegate.
///
/// - Note: In SwiftUI previews you can easily instantiate your own ``Account``. Use initializers like
///     ``Account/init(services:configuration:)`` or ``Account/init(building:active:configuration:)``.
///
///
/// Below is a short code example on how to use the `AccountSetup` view.
///
/// ```swift
/// struct MyView: View {
///     @EnvironmentObject var account: Account
///
///     var body: some View {
///         // You may use `account.signedIn` to conditionally render another view if there is already a signed in account
///         // or use the `continue` closure as shown below to render a Continue button.
///         // The continue button is especially useful in cases like Onboarding Flows such that the user has the chance
///         // to review the currently signed in account.
///
///         AccountSetup {
///            NavigationLink {
///                // ... next view
///            } label: {
///                Text("Continue")
///            }
///         }
///     }
/// }
/// ```
public struct AccountSetup<Header: View, Continue: View>: View {
    private let setupCompleteClosure: (AccountDetails) -> Void
    private let header: Header
    private let continueButton: Continue

    @EnvironmentObject var account: Account

    @State private var setupState: _AccountSetupState = .generic
    @State private var followUpSheet = false

    private var services: [any AccountService] {
        account.registeredAccountServices
            .filter { !($0 is any IdentityProvider) }
    }

    private var identityProviders: [any IdentityProvider] {
        account.registeredAccountServices
            .compactMap { $0 as? any IdentityProvider }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    if !services.isEmpty {
                        header
                            .environment(\._accountSetupState, setupState)
                    }

                    Spacer()

                    if let details = account.details {
                        switch setupState {
                        case let .requiringAdditionalInfo:
                            followUpInformationSheet(details)
                        case .loadingExistingAccount:
                            // We allow the outer view to navigate away upon signup, before we show the existing account view
                            existingAccountLoading
                        default:
                            ExistingAccountView(details: details) {
                                continueButton
                            }
                        }
                    } else {
                        accountSetupView
                            .onAppear {
                                setupState = .setupShown
                            }
                    }

                    Spacer()
                    Spacer()
                    Spacer()
                }
                    .padding(.horizontal, ViewSizing.outerHorizontalPadding)
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
            .onReceive(account.$details) { details in
                if let details, case .setupShown = setupState {
                    let accountKeyIds = Set(details.keys.map { ObjectIdentifier($0) })

                    // TODO are we putting them anywhere? => maybe as the item for the sheet?
                    let missingKeys = account.configuration
                        .all(filteredBy: [.required])
                        .filter { $0.category != .credentials } // don't collect credentials!
                        .filter { key in
                            !accountKeyIds.contains(ObjectIdentifier(key))
                        }

                    if missingKeys.isEmpty {
                        setupState = .loadingExistingAccount
                        setupCompleteClosure(details)
                    } else {
                        setupState = .requiringAdditionalInfo
                    }
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
                .padding(.horizontal, ViewSizing.innerHorizontalPadding)
                .frame(maxWidth: ViewSizing.maxFrameWidth) // landscape optimizations
                .dynamicTypeSize(.medium ... .xxxLarge) // ui doesn't make sense on size larger than .xxxLarge
        }
    }

    @ViewBuilder private var existingAccountLoading: some View {
        ProgressView()
            .task {
                try? await Task.sleep(for: .seconds(2))
                setupState = .generic
            }
    }


    fileprivate init(state: _AccountSetupState) where Header == DefaultAccountSetupHeader, Continue == EmptyView {
        self.setupCompleteClosure = { _ in }
        self.header = DefaultAccountSetupHeader()
        self.continueButton = EmptyView()
        self._setupState = State(initialValue: state)
    }

    public init( // TODo document new behavior and new parameters!
        setupComplete: @escaping (AccountDetails) -> Void = { _ in },
        @ViewBuilder header: () -> Header = { DefaultAccountSetupHeader() },
        @ViewBuilder `continue`: () -> Continue = { EmptyView() }
    ) {
        self.setupCompleteClosure = setupComplete
        self.header = header()
        self.continueButton = `continue`()
    }


    @ViewBuilder
    private func followUpInformationSheet(_ details: AccountDetails) -> some View {
        ProgressView()
            .sheet(isPresented: $followUpSheet) {
                NavigationStack {
                    FollowUpInfoSheet(details: details)
                }
            }
            .onAppear {
                followUpSheet = true // we want full control through the setupState property
            }
            .onChange(of: followUpSheet) { newValue in
                if !newValue { // follow up information was completed!
                    setupState = .loadingExistingAccount
                    setupCompleteClosure(details) // TODO assuming updated?
                }
            }
    }
}


extension EnvironmentValues {
    public var _accountSetupState: _AccountSetupState { // swiftlint:disable:this identifier_name missing_docs
        get {
            self[_AccountSetupState.self]
        }
        set {
            self[_AccountSetupState.self] = newValue
        }
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
            AccountSetup()
                .environmentObject(Account(services: accountServicePermutations[index] + [MockSignInWithAppleProvider()]))
        }

        AccountSetup()
            .environmentObject(Account(building: detailsBuilder, active: MockUserIdPasswordAccountService()))

        AccountSetup(state: .setupShown)
            .environmentObject(Account(building: detailsBuilder, active: MockUserIdPasswordAccountService()))

        AccountSetup(continue: {
            Button(action: {
                print("Continue")
            }, label: {
                Text("Continue")
                    .frame(maxWidth: .infinity, minHeight: 38)
            })
            .buttonStyle(.borderedProminent)
        })
            .environmentObject(Account(building: detailsBuilder, active: MockUserIdPasswordAccountService()))
    }
}
#endif
