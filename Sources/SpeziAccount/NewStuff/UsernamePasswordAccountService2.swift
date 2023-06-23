//
// Created by Andreas Bauer on 22.06.23.
//

import Foundation
import SwiftUI

struct RandomAccountService: AccountServiceNew {
    var viewStyle: RandomAccountServiceViewStyle {
        RandomAccountServiceViewStyle()
    }

    func logout() async throws {}
}

struct RandomAccountServiceViewStyle: AccountServiceViewStyle {
    typealias AccountServiceType = RandomAccountService

    func makeAccountServiceButtonLabel() -> some View {
        Image(systemName: "ellipsis.rectangle")
            .font(.title2)
        Text("Mock Account Service")
    }

    func makePrimaryView() -> some View {
        Text("Hello World")
    }

    func makeAccountSummary() -> some View {
        Text("Conditionally show Account summary, or login stuff!")
    }
}

/*
struct UsernamePasswordAccountService2: KeyPasswordBasedAccountService {
    typealias AccountServiceButtonStyle = PlainButtonStyle // TODO this is not really a great way to deal with that is it?

    func makePrimaryView() -> some View {
        EmptyView()
    }

    func makeSignupView() -> some View {
        EmptyView()
    }

    func makePasswordResetView() -> some View {
        EmptyView()
    }

    func makeDestinationBody() -> some View {
        EmptyView()
    }

    func signUp(values: SignUpValues) {
    }

    private(set) var viewStyle: ViewStyle
}
*/
