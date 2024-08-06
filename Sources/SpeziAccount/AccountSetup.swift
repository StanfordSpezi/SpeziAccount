//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SwiftUI


public enum _AccountSetupState: EnvironmentKey, Sendable { // swiftlint:disable:this type_name
    case generic
    case setupShown
    case requiringAdditionalInfo(_ keys: [any AccountKey.Type])
    case loadingExistingAccount

    public static let defaultValue: _AccountSetupState = .generic
}


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
@MainActor
public struct AccountSetup<Header: View, Continue: View>: View {
    private let setupCompleteClosure: (AccountDetails) -> Void
    private let header: Header
    private let continueButton: Continue

    @Environment(Account.self)
    private var account

    @State private var setupState: _AccountSetupState = .generic
    @State private var followUpSheet = false

    private var hasSetupComponents: Bool {
        account.accountSetupComponents.contains { $0.configuration.isEnabled }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    if hasSetupComponents {
                        header
                            .environment(\._accountSetupState, setupState)
                    }

                    Spacer()

                    if let details = account.details, !details.isAnonymous {
                        switch setupState {
                        case let .requiringAdditionalInfo(keys):
                            followUpInformationSheet(details, requiredKeys: keys)
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
            .onChange(of: account.signedIn) {
                if let details = account.details, case .setupShown = setupState {
                    let missingKeys = account.configuration.missingRequiredKeys(for: details, includeCollected: details.isNewUser)

                    if missingKeys.isEmpty {
                        setupState = .loadingExistingAccount
                        setupCompleteClosure(details)
                    } else {
                        setupState = .requiringAdditionalInfo(missingKeys)
                    }
                }
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

    /// Create a new AccountSetup view.
    /// - Parameters:
    ///   - setupComplete: The closure that is called once the account setup is considered to be completed.
    ///     Note that it may be the case, that there are global account details associated (see ``Account/details``)
    ///     but setup is not completed (e.g., after a login where additional info was required from the user).
    ///   - header: An optional Header view to be displayed.
    ///   - continue: A custom continue button you can place. This view will be rendered if the AccountSetup view is
    ///     displayed with an already associated account.
    public init(
        setupComplete: @escaping (AccountDetails) -> Void = { _ in },
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
            .sheet(isPresented: $followUpSheet) {
                NavigationStack {
                    FollowUpInfoSheet(details: details, requiredKeys: requiredKeys)
                }
            }
            .onAppear {
                followUpSheet = true // we want full control through the setupState property
            }
            .onChange(of: followUpSheet) {
                if !followUpSheet { // follow up information was completed!
                    setupState = .loadingExistingAccount
                    setupCompleteClosure(details)
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
