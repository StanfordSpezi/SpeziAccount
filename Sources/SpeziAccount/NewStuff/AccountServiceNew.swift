//
// Created by Andreas Bauer on 22.06.23.
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
         // TOOD how to handle observeable objects?
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
    associatedtype ButtonLabel: View
    associatedtype PrimaryView: View
    associatedtype AccountSummaryView: View

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

protocol EmbeddableAccountServiceViewStyle: AccountServiceViewStyle {
    associatedtype EmbeddedView: View

    @ViewBuilder
    func makeEmbeddedAccountView() -> EmbeddedView
}

protocol KeyPasswordBasedAccountService: AccountServiceNew, EmbeddableAccountService where ViewStyle: KeyPasswordBasedAccountServiceViewStyle {
    func login(key: String, password: String) async throws

    func signUp(signUpValues: SignUpValues) async throws // TODO refactor SignUpValues property names!

    func resetPassword(key: String) async throws
}

protocol KeyPasswordBasedAccountServiceViewStyle: EmbeddableAccountServiceViewStyle {
    associatedtype SignupView: View
    associatedtype PasswordResetView: View
    // TODO provide embedded primary view (simplified?) ! if its the single element
    // TODO provide a button!
    //  -> Primary View (navigate to sing up if it doesn't exists)
    //  -> Signup View
    //  -> Password Reset view!

    // @ViewBuilder
    // func makePrimaryView() -> PrimaryView // TODO the same thing as the makeDestinationBody!

    @ViewBuilder
    func makeSignupView() -> SignupView

    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView
}

extension KeyPasswordBasedAccountService {
    func makeEmbeddedView() -> some View {
        // TODO make two text fields
        EmptyView()
    }
}
