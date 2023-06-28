//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


/// Display login buttons for all configured ``AccountService``s using the ``Account/Account`` module.
///
/// The view display default Localization: "en",s a list of login buttons as well as a customizable header view that can be defined using the ``Login/init(header:)`` initializer.
public struct Login<Header: View>: View {
    private var header: Header
    
    
    public var body: some View {
        AccountServicesView(header: header) { accountService in
            AnyView(Text("<Login Button>"))
            // TODO accountService.loginButton
        }
            .navigationTitle(String(localized: "LOGIN", bundle: .module))
    }
    
    
    public init() where Header == EmptyView {
        self.header = EmptyView()
    }
    
    /// - Parameter header: A SwiftUI `View` displayed as a header above all login buttons.
    public init(@ViewBuilder header: () -> Header) {
        self.header = header()
    }
}


#if DEBUG
struct Login_Previews: PreviewProvider {
    // @StateObject private static var account = Account(accountServices: [UsernamePasswordAccountService(), EmailPasswordAccountService()])
    @StateObject private static var emptyAccount = Account(accountServices: [])
    
    static var previews: some View {
        /*
        NavigationStack {
            Login()
        }
            .environmentObject(account)
        */

        NavigationStack {
            Login()
        }
            .environmentObject(emptyAccount)
    }
}
#endif
