//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct RandomAccountService: AccountServiceNew {
    var viewStyle: RandomAccountServiceViewStyle {
        RandomAccountServiceViewStyle(accountService: self)
    }

    func logout() async throws {}
}

struct RandomAccountServiceViewStyle: AccountServiceViewStyle {
    var accountService: RandomAccountService

    func makeAccountServiceButtonLabel() -> some View {
        // TODO this method is currently called label, but the AccountServiceButton is called button => confusing!
        AccountServiceButton {
            Image(systemName: "ellipsis.rectangle")
                .font(.title2)
            Text("Mock Account Service")
        }
    }

    func makePrimaryView() -> some View {
        Text("Hello World")
    }

    func makeAccountSummary() -> some View {
        Text("Conditionally show Account summary, or login stuff!")
    }
}

// TODO we have final class requirement ://
struct DefaultUsernamePasswordAccountService: KeyPasswordBasedAccountService {
    typealias ViewStyle = DefaultUsernamePasswordAccountServiceViewStyle

    func login(key: String, password: String) async throws {
        print("login \(key) \(password)")
    }

    func signUp(signUpValues: SignUpValues) async throws {
        print("signup \(signUpValues)")
    }

    func resetPassword(key: String) async throws {
        print("resetPassword \(key)")
    }

    // TODO this has to be a computed property!
    var viewStyle: DefaultUsernamePasswordAccountServiceViewStyle {
        DefaultUsernamePasswordAccountServiceViewStyle(accountService: self)
    }

    func logout() async throws {
        print("logout")
    }
}

struct DefaultUsernamePasswordAccountServiceViewStyle: KeyPasswordBasedAccountServiceViewStyle {
    var accountService: DefaultUsernamePasswordAccountService

    func makeAccountServiceButtonLabel() -> some View {
        // TODO how to generate a sensible default!
        AccountServiceButton {
            Text("Default button!")
        }
    }

    func makeAccountSummary() -> some View {
        // TODO default implementation!
        Text("Placeholder account summary!")
    }
}
