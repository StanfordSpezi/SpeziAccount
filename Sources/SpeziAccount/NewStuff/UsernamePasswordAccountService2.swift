//
// Created by Andreas Bauer on 22.06.23.
//

import Foundation
import SwiftUI

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
}
