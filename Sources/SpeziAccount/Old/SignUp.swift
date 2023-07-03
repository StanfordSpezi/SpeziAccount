//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// Display sign up buttons for all configured ``AccountService``s using the ``Account/Account`` module.
///
/// The view displays a list of sign up buttons as well as a customizable header view that can be defined using the ``Login/init(header:)`` initializer.
public struct SignUp<Header: View>: View {
    private var header: Header
    
    
    public var body: some View {
        AccountServicesView(header: header) { accountService in
            AnyView(Text("<SignUp Button>"))
            // TODO accountService.signUpButton
        }
            .navigationTitle(String(localized: "SIGN_UP", bundle: .module))
    }
    
    
    public init() where Header == EmptyView {
        self.header = EmptyView()
    }
    
    /// - Parameter header: A SwiftUI `View` displayed as a header above all login buttons.
    public init(@ViewBuilder header: () -> (Header)) {
        self.header = header()
    }
}


#if DEBUG
struct SignUp_Previews: PreviewProvider {
    @StateObject private static var account: Account = {
        let accountServices: [any AccountService] = [
            // UsernamePasswordAccountService(),
            // EmailPasswordAccountService()
        ]
        return Account(services: accountServices)
    }()
    
    static var previews: some View {
        NavigationStack {
            SignUp()
        }
            .environmentObject(account)
    }
}
#endif
