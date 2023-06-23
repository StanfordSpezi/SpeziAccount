//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO make everything public!

// TODO app needs access to the "primary?"/signed in (we don't support multi account sign ins!) account service!
//  -> logout functionality
//  -> AccountSummary
//  -> allows for non-account-service-specific app implementations (e.g., easily switch for testing) => otherwise cast!

protocol AccountServiceNew {
    associatedtype ViewStyle: AccountServiceViewStyle

    // TODO provide access to `Account` to communicate changes back to the App

    var viewStyle: ViewStyle { get }
    var configuration: AccountServiceViewConfiguration<Self> { get }

    func logout() async throws
}

extension AccountServiceNew {
    var configuration: AccountServiceViewConfiguration<Self> {
        AccountServiceViewConfiguration(accountService: self)
    }
}

struct AccountServiceEnvironmentKey: EnvironmentKey {
    static var defaultValue: (any AccountServiceNew)?
}

extension EnvironmentValues {
    var anyAccountService: (any AccountServiceNew)? {
        get {
            self[AccountServiceEnvironmentKey.self]
        }
        set {
            self[AccountServiceEnvironmentKey.self] = newValue
        }
    }
}

@propertyWrapper
struct AccountServiceProperty<Service: AccountServiceNew>: DynamicProperty { // TODO name clash!
    @Environment(\.anyAccountService)
    private var anyAccountService

    // TODO we use EnvironmentObject to allow to trigger updates????
    // @EnvironmentObject
    // private var accountServiceObject: Service

    @MainActor
    var wrappedValue: Service {
        // TODO refactor to guard!
        if let anyService = anyAccountService {
            guard let typedService = anyService as? Service else {
                // fair to raise an fatal error, environment object does the same!
                fatalError("Tried accessing AccountService from the Environment expecting \(Service.self) but received type \(type(of: anyService))!")
            }

            return typedService
        }

        fatalError("Failed to inject account service!")
    }
}


extension AccountServiceNew {
    func injectAccountService<V: View>(into view: V) -> some View {
        /*
         // TODO how to handle observable objects?
        if let observable = self as? any AccountServiceNew & ObservableObject {
            return observable
                .injectAccountServiceAsEnvironmentObject(into: view)
                .environment(\.anyAccountService, self)
        }
        */

        return view
            .environment(\.anyAccountService, self)
    }
}

extension AccountServiceNew where Self: ObservableObject {
    func injectAccountServiceAsEnvironmentObject<V: View>(into view: V) -> some View {
        print("Injecting \(Self.self)") // TODO remove debug!
        return view
            .environmentObject(self) // TODO test that this works!!
    }
}
/*
 // TODO we might consider adding that back?
extension AccountServiceNew {
    func injectViewStyle<V: View>(into view: V) -> some View {
        print("Injecting \(Self.self)") // TODO remove debug!
        return view
            .environmentObject(self) // TODO test that this works!!
            // TODO how would the default implementation of KeyPasswordBasedAccountServiceStyle access KeyPasswordBasedAccountService
    }
}
*/

struct AccountServiceViewConfiguration<Service: AccountServiceNew> {
    let accountService: Service
}

protocol AccountServiceViewStyle { // TODO is naming accurate?
    associatedtype Service: AccountServiceNew

    associatedtype ButtonLabel: View
    associatedtype PrimaryView: View
    associatedtype AccountSummaryView: View

    // TODO that's not really a great way to deal with that?
    var accountService: Service { get set }

    // TODO configuration input
    @ViewBuilder
    func makeAccountServiceButtonLabel() -> ButtonLabel

    // TODO configuration input
    @ViewBuilder
    func makePrimaryView() -> PrimaryView

    @ViewBuilder
    func makeAccountSummary() -> AccountSummaryView
}

protocol EmbeddableAccountService: AccountServiceNew where ViewStyle: EmbeddableAccountServiceViewStyle {
}

protocol EmbeddableAccountServiceViewStyle: AccountServiceViewStyle where Service: EmbeddableAccountService {
    associatedtype EmbeddedView: View

    @ViewBuilder
    func makeEmbeddedAccountView() -> EmbeddedView
}
