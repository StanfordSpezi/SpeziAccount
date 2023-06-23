//
// Created by Andreas Bauer on 22.06.23.
//

import Foundation
import SwiftUI

// TODO make everything public!

protocol AccountServiceNew {
    // TODO provide a button style for the external button!
    associatedtype AccountServiceButtonStyle: PrimitiveButtonStyle
    associatedtype ButtonDestination: View
    // TODO label for the button?


    // TODO configuration?
    func makeDestinationBody() -> ButtonDestination

    func signUp(values: SignUpValues) // TODO ???
}

extension AccountServiceNew {
    func makeButton() -> AnyView {
        AnyView(Button(action: {}, label: {

        }))
           // TODO  .buttonStyle(AccountServiceButtonStyle())) it doesnt require a init!
    }
}

protocol EmbeddableAccountService: AccountServiceNew {
    associatedtype EmbeddedView: View

    @ViewBuilder
    func makeEmbeddedView() -> EmbeddedView
}

/// An ``AccountServiceNew``
protocol KeyPasswordBasedAccountService: AccountServiceNew, EmbeddableAccountService {
    associatedtype PrimaryView: View // login view!
    associatedtype SignupView: View
    associatedtype PasswordResetView: View
    // TODO provide embedded primary view (simplified?) ! if its the single element
    // TODO provide a button!
    //  -> Primary View (navigate to sing up if it doesn't exists)
    //  -> Signup View
    //  -> Password Reset view!

    @ViewBuilder
    func makePrimaryView() -> PrimaryView // TODO the same thing as the makeDestinationBody!

    @ViewBuilder
    func makeSignupView() -> SignupView

    @ViewBuilder
    func makePasswordResetView() -> PasswordResetView
}

extension KeyPasswordBasedAccountService {
    func makeEmbeddedView() -> some View {
        // TODO make two text fields
        return EmptyView()
    }
}
