//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SpeziViews
import SwiftUI


/// Login or signup for a user account.
///
/// This view handles account setup for a user. It will show all enabled ``IdentityProvider``s from the configured ``AccountService``.
/// Account setup or login is then handled through the view components provided by the `AccountService`.
///
/// - Note: This view relies on an ``Account`` object in its environment. This is done automatically by providing a
/// ``AccountConfiguration`` in the configuration section of your `Spezi` app delegate.
///
/// Below is a short code example on how to use the `AccountSetup` view.
///
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         // You may use `account.signedIn` to conditionally render another view if there is already a signed in account
///         // or use the `continue` closure as shown below to render a Continue button.
///         // The continue button is especially useful in cases like Onboarding Flows such that the user has the chance
///         // to review the currently signed in account.
///
///         AccountSetup()
///     }
/// }
/// ```
///
/// - Note: Use the ``Account`` module to access the current user details and check if the is currently a user ``Account/signedIn``.
///
/// If you are using the `AccountSetup` view in an onboarding flow, it might be the case that an account is already present.
/// The view then displays the currently logged-in user to give the user a change to review the user account in place.
/// `AccountSetup` allows to place additional view components in this subview (e.g., to have a continue button that handles further navigation).
///
/// ```swift
/// AccountSetup {
///     Button {
///         // handle navigation
///     } label: {
///         Text("Continue")
///             .frame(maxWidth: .infinity, minHeight: 38)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Header
/// - ``DefaultAccountSetupHeader``
///
/// ### Setup State
/// - ``SwiftUICore/EnvironmentValues/accountSetupState``
/// - ``AccountSetupState``
@MainActor
public struct AccountSetup<Header: View, Continue: View>: View {
    private let setupCompleteClosure: @MainActor (AccountDetails) async -> Void
    private let header: Header
    private let continueButton: Continue

    @Environment(Account.self)
    private var account
    @Environment(\.followUpBehavior)
    private var followUpBehavior

    @State private var setupState: AccountSetupState = .presentingExistingAccount
    @State private var compliance: SignupProviderCompliance?
    @State private var presentFollowUpSheet = false
    @State private var accountSetupTask: Task<Void, Never>?

    private var hasSetupComponents: Bool {
        account.accountSetupComponents.contains { $0.configuration.isEnabled }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                scrollableContentView
                    .padding(.horizontal, ViewSizing.outerHorizontalPadding)
                    .frame(minHeight: proxy.size.height)
                    .frame(maxWidth: .infinity)
            }
        }
            .onChange(of: [account.signedIn, account.details?.isAnonymous]) {
                guard case .presentingSignup = setupState,
                      let details = account.details,
                      !details.isAnonymous else {
                    return
                }

                handleSuccessfulSetup(details)
            }
            .onDisappear {
                accountSetupTask?.cancel()
            }
    }
    
    @ViewBuilder private var scrollableContentView: some View {
        VStack {
            if hasSetupComponents {
                header
                    .environment(\.accountSetupState, setupState)
            }
            Spacer()
            if let details = account.details, !details.isAnonymous {
                switch setupState {
                case let .requiringAdditionalInfo(keys):
                    followUpInformationSheet(details, requiredKeys: keys)
                case .loadingExistingAccount, .presentingSignup:
                    ProgressView()
                case .presentingExistingAccount:
                    ExistingAccountView(details: details) {
                        continueButton
                    }
                }
            } else {
                accountSetupView
                    .onAppear {
                        setupState = .presentingSignup
                    }
            }
            Spacer()
            Spacer()
            Spacer()
        }
    }

    @ViewBuilder private var accountSetupView: some View {
        if !hasSetupComponents {
            EmptyServicesWarning()
        } else {
            VStack {
                let categorized = account.accountSetupComponents.reduce(into: OrderedDictionary()) { partialResult, component in
                    guard component.configuration.isEnabled else {
                        return
                    }
                    partialResult[component.configuration.section] = component
                }

                ForEach(categorized.keys.sorted(), id: \.self) { placement in
                    if let component = categorized[placement] {
                        component.anyView

                        if categorized.keys.last != placement {
                            ServicesDivider()
                        }
                    }
                }
            }
                .padding(.horizontal, ViewSizing.innerHorizontalPadding)
                .frame(maxWidth: ViewSizing.maxFrameWidth) // landscape optimizations
                .dynamicTypeSize(.medium ... .xxxLarge) // ui doesn't make sense on size larger than .xxxLarge
                .receiveSignupProviderCompliance { compliance in
                    self.compliance = compliance
                }
        }
    }
    

    fileprivate init(state: AccountSetupState) where Header == DefaultAccountSetupHeader, Continue == EmptyView {
        self.setupCompleteClosure = { _ in }
        self.header = DefaultAccountSetupHeader()
        self.continueButton = EmptyView()
        self._setupState = State(initialValue: state)
    }

    /// Create a new AccountSetup view.
    /// - Parameters:
    ///   - setupComplete: The closure that is called once the account setup is considered to be completed.
    ///     Note that it may be the case, that there are global account details associated (see ``Account/details``)
    ///     but setup is not completed (e.g., after a login where additional info was required from the user).
    ///   - header: An optional Header view to be displayed.
    ///   - continue: A custom continue button you can place. This view will be rendered if the AccountSetup view is
    ///     displayed with an already associated account.
    public init(
        setupComplete: @MainActor @escaping (AccountDetails) async -> Void = { _ in try? await Task.sleep(for: .seconds(2)) },
        @ViewBuilder header: () -> Header = { DefaultAccountSetupHeader() },
        @ViewBuilder `continue`: () -> Continue = { EmptyView() }
    ) {
        self.setupCompleteClosure = setupComplete
        self.header = header()
        self.continueButton = `continue`()
    }


    @ViewBuilder
    private func followUpInformationSheet(_ details: AccountDetails, requiredKeys: [any AccountKey.Type]) -> some View {
        ProgressView()
            .sheet(isPresented: $presentFollowUpSheet) {
                // follow up information was completed!
                handleSetupCompleted(details)
            } content: {
                NavigationStack {
                    FollowUpInfoSheet(keys: requiredKeys)
                }
            }
            .onAppear {
                // setupState made this view show up, therefore, automatically present the sheet
                presentFollowUpSheet = true
            }
    }

    private func handleSuccessfulSetup(_ details: AccountDetails) {
        var includeCollected: AccountValueConfiguration.IncludeCollectedType
        let ignoreCollected: [any AccountKey.Type]

        switch followUpBehavior {
        case .disabled:
            handleSetupCompleted(details)
            return
        case .minimal:
            includeCollected = .onlyRequired
        case .redundant:
            includeCollected = .includeCollectedAtLeastOneRequired
        }

        // If the provider was not able to present all details and it is a new user we always include collected.
        // This applies to both followUpBehaviors.
        if details.isNewUser,
           case let .only(keys) = compliance?.visualizedAccountKeys {
            includeCollected = .includeCollected
            ignoreCollected = keys
        } else {
            ignoreCollected = []
        }

        let missingKeys = account.configuration.missingRequiredKeys(for: details, includeCollected, ignoring: ignoreCollected)

        if !missingKeys.isEmpty {
            setupState = .requiringAdditionalInfo(missingKeys)
        } else {
            handleSetupCompleted(details)
        }
    }

    private func handleSetupCompleted(_ details: AccountDetails) {
        setupState = .loadingExistingAccount
        accountSetupTask?.cancel()
        accountSetupTask = Task { @MainActor in
            await setupCompleteClosure(details)
            setupState = .presentingExistingAccount
        }
    }
}


#if DEBUG
#Preview {
    AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(configure: .all))
        }
}

#Preview {
    AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(configure: .userIdPassword))
        }
}

#Preview {
    AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(configure: [.userIdPassword, .signInWithApple]))
        }
}

#Preview {
    AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(configure: .customIdentityProvider))
        }
}

#Preview {
    AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(configure: .signInWithApple))
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return AccountSetup()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return AccountSetup(state: .loadingExistingAccount)
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    
    return NavigationStack {
        AccountSetup(continue: {
            Button {
                print("Continue")
            } label: {
                Text(verbatim: "Continue")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
        })
            .previewWith {
                AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
            }
    }
}
#endif
